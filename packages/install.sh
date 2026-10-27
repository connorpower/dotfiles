#!/usr/bin/env bash

# Fail fast and fail early.
#   - Abort script at first error
#   - Attempts to use undefined variable outputs error message and exits
#   - Pipelines return the exit status of the last command in the pipe to fail
#
set -euo pipefail

###############################################################################
# CONSTANTS
###############################################################################

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
SCRIPT=$(basename "${0}")
OS="$(${DIR}/../bin/detect-os)"
PACKAGE_LIST="${DIR}/packages.yml"

declare -a CATEGORIES=(
    'base'
    'personal'
    'work'
)

# Install steps that failed. A failure is recorded and the run carries on, so
# one bad package doesn't hide the next. report_failures prints the list.
declare -a FAILED=()

# Debian packages that come from a repository bootstrap() adds. They are not
# in apt until bootstrap() has run, so --check can't see them on a fresh
# machine. Keep in step with the repositories added in bootstrap().
declare -a BOOTSTRAP_REPO_PKGS=(
    'neovim'
    'terraform'
    'acli'
)

###############################################################################
# MAIN
###############################################################################

main() {
    # Be nice and check for all common help flags
    if [[ $# -gt 0 ]]; then
        if [[ "${1}" = "help" ]] || [[ "${1}" = "--help" ]]; then
            print_help
            return 0
        fi
    fi

    local dry_run=''
    local mode='install'

    while getopts ":hdcv" o; do
        case "${o}" in
            h)
                print_help
                return 0
                ;;
            d)
                dry_run='echo'
                ;;
            c)
                mode='check'
                ;;
            v)
                mode='verify'
                ;;
            *)
                print_usage >&2
                return 1
                ;;
        esac
    done
    shift $((OPTIND-1))

    cats=( "$@" )

    if [[ "${mode}" != 'install' ]]; then
        if [[ ${#cats[@]} -eq 0 ]]; then
            echo "--${mode} needs at least one category: ${CATEGORIES[*]}" >&2
            return 1
        fi
        if ! command -v yq &> /dev/null; then
            echo "yq is required to read ${PACKAGE_LIST}" >&2
            return 1
        fi
        # An unreadable list would otherwise look like nothing to check.
        if ! yq '.packages | keys' "${PACKAGE_LIST}" &> /dev/null; then
            echo "yq could not read ${PACKAGE_LIST}" >&2
            return 1
        fi
        # Both modes only read, so they need no sudo and no bootstrap.
        if [[ "${mode}" == 'check' ]]; then
            check_all
        else
            verify_commands
        fi
        report_failures
        return
    fi

    # Refresh sudo credentials in case we need it
    ${dry_run} sudo -v
    bootstrap
    install_all
    configure
    # A dry run installs nothing, so there is nothing to verify.
    if [[ -z "${dry_run}" ]]; then
        verify_commands
    fi
    report_failures
}


###############################################################################
# FUNCTIONS
###############################################################################

function bootstrap() {
    case "${OS}" in
        'darwin')
            xcode-select -p &>/dev/null || ${dry_run} xcode-select --install

            # Homebrew and every compile step refuse to run while the Xcode
            # license is outstanding. `xcodebuild -license check` exits 69 in
            # that state. Skip the check on a Command Line Tools only machine,
            # where `xcodebuild` is absent and no agreement is pending.
            local developer_dir
            developer_dir="$(xcode-select -p 2>/dev/null || true)"
            if [[ "${developer_dir}" == *Xcode.app* ]] \
                && ! xcodebuild -license check &> /dev/null; then
                ${dry_run} sudo xcodebuild -license accept
            fi

            if ! command -v brew &> /dev/null; then
                ${dry_run} /bin/bash -c \
                    "$(${dry_run} curl \
                        --proto '=https' \
                        --tlsv1.2 \
                        -sSf \
                        https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh \
                    )"
            fi

            # The installer doesn't touch PATH for the current process, so make
            # brew usable for the rest of this script.
            if ! command -v brew &> /dev/null; then
                for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
                    [ -x "${brew_bin}" ] && eval "$("${brew_bin}" shellenv)" && break
                done
            fi

            pkg_install yq

            # Terraform was relicensed (BUSL) and removed from homebrew/core;
            # it now lives only in HashiCorp's own tap.
            ${dry_run} brew tap hashicorp/tap
            brew_trust hashicorp/tap/terraform

            # omp ships only in its author's tap.
            ${dry_run} brew tap can1357/tap
            brew_trust can1357/tap/omp

            # idb and acli ship only in their vendors' taps, and no personal
            # machine installs either. Tap on a work install alone.
            if [[ " ${cats[*]:-} " == *' work '* ]]; then
                ${dry_run} brew tap facebook/fb
                ${dry_run} brew tap atlassian/homebrew-acli
                brew_trust facebook/fb/idb-cli
                brew_trust facebook/fb/idb-companion
                brew_trust atlassian/acli/acli
            fi
            ;;
	'debian')
	    ${dry_run} sudo apt-get update
	    ${dry_run} sudo apt-get upgrade -y
            ${dry_run} sudo apt-get install -y build-essential
            ${dry_run} sudo apt-get install -y cmake
	    ${dry_run} sudo apt-get install -y libssl-dev
	    ${dry_run} sudo apt-get install -y pkg-config
	    ${dry_run} sudo apt-get install -y software-properties-common
	    if ! locale -a 2>/dev/null | grep -q 'en_US.utf8'; then
	        ${dry_run} sudo locale-gen en_US.UTF-8
	    fi
	    # yq (Go version): direct binary — snap requires systemd which may not run in WSL2
	    if ! command -v yq &> /dev/null; then
	        ARCH=$(dpkg --print-architecture)
	        ${dry_run} sudo wget -qO /usr/local/bin/yq \
	            "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${ARCH}"
	        ${dry_run} sudo chmod a+rx /usr/local/bin/yq
	    fi
	    # neovim-ppa/unstable tracks latest stable nvim releases (0.11+)
	    if ! apt-cache policy | grep -q neovim-ppa; then
	        ${dry_run} sudo add-apt-repository -y ppa:neovim-ppa/unstable
	        ${dry_run} sudo apt-get update
	    fi
	    # acli ships in Atlassian's own apt repository, and no personal machine
	    # installs it. Add the repository on a work install alone. The key is
	    # dearmored into /etc/apt/keyrings and named in the sources entry, so
	    # it signs this repository and nothing else.
	    if [[ " ${cats[*]:-} " == *' work '* ]] \
	        && [ ! -f /etc/apt/sources.list.d/acli.list ]; then
	        ${dry_run} sudo apt-get install -y wget gnupg2
	        ${dry_run} sudo mkdir -p -m 755 /etc/apt/keyrings
	        ${dry_run} sudo sh -c 'wget -nv -O- https://acli.atlassian.com/gpg/public-key.asc | gpg --dearmor -o /etc/apt/keyrings/acli-archive-keyring.gpg'
	        ${dry_run} sudo chmod go+r /etc/apt/keyrings/acli-archive-keyring.gpg
	        ${dry_run} sudo sh -c "echo 'deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/acli-archive-keyring.gpg] https://acli.atlassian.com/linux/deb stable main' > /etc/apt/sources.list.d/acli.list"
	        ${dry_run} sudo apt-get update
	    fi
	    # terraform ships in HashiCorp's own apt repository. The key is
	    # dearmored into /etc/apt/keyrings and named in the sources entry, so
	    # it signs this repository and nothing else.
	    if [ ! -f /etc/apt/sources.list.d/hashicorp.list ]; then
	        ${dry_run} sudo mkdir -p -m 755 /etc/apt/keyrings
	        ${dry_run} sudo sh -c 'wget -nv -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /etc/apt/keyrings/hashicorp-archive-keyring.gpg'
	        ${dry_run} sudo chmod go+r /etc/apt/keyrings/hashicorp-archive-keyring.gpg
	        ${dry_run} sudo sh -c "echo 'deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main' > /etc/apt/sources.list.d/hashicorp.list"
	        ${dry_run} sudo apt-get update
	    fi
	    # nvm
	    if [ ! -s "${HOME}/.nvm/nvm.sh" ]; then
	        ${dry_run} curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
	    fi
	    # shellcheck source=/dev/null
	    source "${HOME}/.nvm/nvm.sh"
	    # `nvm ls` appends the alias list, and that list always carries an
	    # lts/* line, so a grep for 'lts' matches on a machine that has nvm
	    # and no node at all. Test for node itself. Sourcing nvm.sh activates
	    # the default alias, so an absent node means nothing is installed.
	    # The npm key below needs npm on PATH for the rest of this script.
	    if ! command -v node &> /dev/null; then
	        ${dry_run} nvm install --lts
	    fi
	    ;;
        *)
            echo 'Unknown OS' >&2
            print_usage
            exit 1
            ;;
    esac

    # An existing toolchain may already be installed but not yet on PATH for
    # this process — source its env before deciding whether to install.
    # shellcheck source=/dev/null
    if [ -s "${HOME}/.cargo/env" ]; then
        source "${HOME}/.cargo/env"
    fi

    if ! command -v rustup &> /dev/null; then
        # -y: don't prompt; this script is meant to run unattended.
        ${dry_run} /bin/bash -c \
            "$(${dry_run} curl \
                --proto '=https' \
                --tlsv1.2 \
                -sSf https://sh.rustup.rs \
            )" '' -y
    fi
    # Make cargo available in the current session if rustup just installed it
    # shellcheck source=/dev/null
    if [ -s "${HOME}/.cargo/env" ]; then
        source "${HOME}/.cargo/env"
    fi

    # A rustup that carries no default toolchain answers every cargo call with
    # "rustup could not choose a version of cargo to run". Debian's rustup
    # package installs the shims and stops there, and it owns /usr/bin/cargo,
    # so the check above finds rustup and skips the installer that would have
    # set a toolchain. Set one here instead.
    if command -v rustup &> /dev/null && ! rustup default &> /dev/null; then
        ${dry_run} rustup default stable
    fi

    # `rustup default stable` selects the channel and never updates it, so a
    # toolchain installed long ago stays on its old release and newer crates
    # fail with "requires rustc X". Update on every run.
    if command -v rustup &> /dev/null; then
        ${dry_run} rustup update stable
        # zsh/zsh.d/rust.zsh updates the toolchain on the first cargo call each
        # week and reads this stamp, so record that an update just happened.
        if [[ -z "${dry_run}" ]]; then
            mkdir -p "${XDG_STATE_HOME:-${HOME}/.local/state}"
            touch "${XDG_STATE_HOME:-${HOME}/.local/state}/rust-toolchain-updated"
        fi
    fi
}

# Install a package with the os-specific package manager
#
# Arguments
# $1: package name (required)
function pkg_install() (
    echo "installing ${1}..."
    case "${OS}" in
        'darwin')
            # Don't quote "$1" to allow parsing args like "--cask cask-name"
            ${dry_run} brew install $1
            ;;
	'debian')
	    ${dry_run} sudo apt-get install -y "${1}"
	    ;;
        *)
            exit 1 # unreachable
            ;;
    esac
)

# Homebrew refuses to load a formula from a third-party tap until the formula
# is trusted, and answers `brew install` with "Refusing to load formula ...
# from untrusted tap" until then. The trust store is ~/.homebrew/trust.json,
# which bootstrap.sh links to homebrew/trust.json in this repo. Write only the
# entries that are missing, so a normal run leaves that linked file alone. A
# Homebrew without `brew trust` needs no trust, so skip the call there.
#
# Arguments
# $1: fully qualified formula name, e.g. 'hashicorp/tap/terraform'
function brew_trust() (
    brew trust --help &> /dev/null || return 0
    if brew trust --json v1 2>/dev/null | grep -qF "\"${1}\""; then
        return 0
    fi
    ${dry_run} brew trust --formula "${1}"
)

function cargo_install() {
    ${dry_run} cargo install --locked "${1}"
}

# Install a global npm package. npm resolves the latest version on every run,
# so this installs and updates alike.
#
# Arguments
# $1: package name, e.g. '@nanonets/graft'
function npm_install() (
    echo "installing ${1}..."
    ${dry_run} npm install -g "${1}"
)

# Install a tool via its own curl-piped install script, skipping it if the
# tool is already on PATH.
#
# Arguments
# $1: 'name@url' pair, e.g. 'herdr@https://herdr.dev/install.sh'
function script_install() (
    local name="${1%%@*}"
    local url="${1#*@}"

    if command -v "${name}" &> /dev/null; then
        return 0
    fi

    echo "installing ${name}..."
    # Fetch first. `sh -c "$(curl ...)"` runs an empty script, and succeeds,
    # when the download fails.
    local script
    script="$(${dry_run} curl -fsSL "${url}")" || return 1
    ${dry_run} sh -c "${script}"
)

# Installs actionlint from its GitHub release into ~/.local/bin, after
# checking the archive against the release's checksums file.
function install_actionlint() (
    echo "installing actionlint..."
    if [[ -n "${dry_run}" ]]; then
        echo "download the actionlint release archive, verify its sha256, install it to ~/.local/bin"
        return 0
    fi

    local arch version tmp archive url
    case "$(uname -m)" in
        'x86_64') arch='amd64' ;;
        'aarch64') arch='arm64' ;;
        *) echo "actionlint: unsupported architecture $(uname -m)" >&2; return 1 ;;
    esac

    # /releases/latest redirects to /releases/tag/v<version>.
    version="$(curl -fsSLI -o /dev/null -w '%{url_effective}' \
        https://github.com/rhysd/actionlint/releases/latest)" || return 1
    version="${version##*/v}"
    [[ -n "${version}" ]] || return 1

    archive="actionlint_${version}_linux_${arch}.tar.gz"
    url="https://github.com/rhysd/actionlint/releases/download/v${version}"
    tmp="$(mktemp -d)"
    trap 'rm -rf "${tmp}"' EXIT

    curl -fsSL "${url}/${archive}" -o "${tmp}/${archive}" || return 1
    curl -fsSL "${url}/actionlint_${version}_checksums.txt" -o "${tmp}/checksums.txt" || return 1
    (cd "${tmp}" && grep " ${archive}\$" checksums.txt | sha256sum -c -) || return 1
    tar -xzf "${tmp}/${archive}" -C "${tmp}" actionlint || return 1
    install -m 0755 "${tmp}/actionlint" "${HOME}/.local/bin/actionlint"
)

function configure() {
    # apt ships bat as batcat and fd as fdfind, because both names were taken
    # by older packages. The zsh config and gitconfig call them bat and fd.
    if [[ "${OS}" == 'debian' ]]; then
        ${dry_run} mkdir -p "${HOME}/.local/bin"
        if [ -x /usr/bin/batcat ] && [ ! -e "${HOME}/.local/bin/bat" ]; then
            ${dry_run} ln -s /usr/bin/batcat "${HOME}/.local/bin/bat"
        fi
        if [ -x /usr/bin/fdfind ] && [ ! -e "${HOME}/.local/bin/fd" ]; then
            ${dry_run} ln -s /usr/bin/fdfind "${HOME}/.local/bin/fd"
        fi
        PATH="${HOME}/.local/bin:${PATH}"
    fi

    # actionlint: no apt package on the Ubuntu releases supported here, and it
    # is a Go binary, so cargo can't build it. brew packages it.
    if [[ "${OS}" == 'debian' ]] && ! command -v actionlint &> /dev/null; then
        attempt configure install_actionlint
    fi

    # aws-cli v2: not available via apt, requires unzip (installed via packages.yml)
    if [[ "${OS}" == 'debian' ]] && ! command -v aws &> /dev/null; then
        ARCH=$(uname -m)
        ${dry_run} curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip" -o /tmp/awscliv2.zip
        ${dry_run} unzip -q /tmp/awscliv2.zip -d /tmp
        ${dry_run} sudo /tmp/aws/install
        ${dry_run} rm -rf /tmp/aws /tmp/awscliv2.zip
    fi

    case "${OS}" in
        'debian')
            if [[ "${SHELL}" != "$(command -v zsh)" ]]; then
                ${dry_run} sudo usermod -s "$(command -v zsh)" "${USER}"
                echo "Default shell changed to zsh — takes effect on next login"
            fi
            ;;
    esac

    # gpg-agent reads its config once at startup, so the pinentry-mac entry in
    # gpg-agent.conf only takes effect after a restart.
    if [[ "${OS}" == 'darwin' ]] && command -v gpgconf &> /dev/null; then
        ${dry_run} gpgconf --kill gpg-agent
    fi

    if command -v git-lfs &> /dev/null; then
        ${dry_run} git lfs install
    fi

    if command -v tldr &> /dev/null; then
        ${dry_run} tldr --update
    fi

    if command -v bat &> /dev/null; then
        ${dry_run} bat cache --build
    fi
}

# Run an install step in a subshell and record it when it fails, instead of
# letting `set -e` end the whole run at the first bad package.
#
# `set -e` is off inside an `if`, so a step fails only through the status of
# its last command. End each step with the command that does the install.
#
# Arguments
# $1: category, for the failure report
# $2...: the command to run
function attempt() {
    local category="${1}"
    shift
    # stdin is closed so the step can't consume the package list being read.
    if ! ("$@") </dev/null; then
        FAILED+=("${category}: $*")
    fi
}

function report_failures() {
    if [[ ${#FAILED[@]} -eq 0 ]]; then
        return 0
    fi
    echo >&2
    echo "These steps failed:" >&2
    printf '  %s\n' "${FAILED[@]}" >&2
    return 1
}

# Prints the entries under packages.<category><path>, one per line.
#
# Arguments
# $1: category
# $2: yq path below the category, e.g. '.universal' or '."cargo-debian"'
function entries() {
    yq ".packages.${1}${2} // [] | .[]" "${PACKAGE_LIST}" | tr -d '"'
}

# Checks that one entry exists at its source, without installing it.
# Returns 0 when it exists, 1 when it does not and 2 when it can't be checked.
#
# Arguments
# $1: kind: pkg, cargo, script or npm
# $2: the entry as written in packages.yml
function check_entry() {
    local kind="${1}"
    local entry="${2}"

    case "${kind}" in
        'pkg')
            case "${OS}" in
                'debian')
                    # Capture first: under pipefail, grep -q closing the pipe
                    # early makes apt-cache fail with SIGPIPE.
                    local policy
                    policy="$(apt-cache policy "${entry}" 2>/dev/null)" || true
                    if [[ "${policy}" == *'Candidate: '[!\(]* ]]; then
                        return 0
                    fi
                    # Not in apt yet, but a repository bootstrap() adds has it.
                    [[ " ${BOOTSTRAP_REPO_PKGS[*]} " == *" ${entry} "* ]] && return 2
                    return 1
                    ;;
                'darwin')
                    # A formula from a third-party tap is unknown until tapped.
                    [[ "${entry}" == */*/* ]] && return 2
                    brew info "${entry}" &> /dev/null
                    ;;
                *)
                    return 2
                    ;;
            esac
            ;;
        'cargo')
            local crate="${entry%%@*}"
            local version=''
            [[ "${entry}" == *@* ]] && version="${entry#*@}"
            # crates.io asks for one request a second and a User-Agent.
            sleep 1
            curl -fs --max-time 20 -A 'dotfiles-install-check' -o /dev/null \
                "https://crates.io/api/v1/crates/${crate}${version:+/${version}}"
            ;;
        'script')
            curl -fsL --max-time 30 -r 0-0 -o /dev/null "${entry#*@}"
            ;;
        'npm')
            command -v npm &> /dev/null || return 2
            npm view "${entry}" version &> /dev/null
            ;;
    esac
}

# Checks every entry install_all would install for this OS: that the package
# exists in its package manager, the crate and version on crates.io, and the
# install script URL. Nothing is installed. A package missing from the oldest
# supported OS is the usual way this installer breaks, and this finds it
# before an install does.
function check_all() {
    local checked=0 missing=0 skipped=0
    local category kind path entry status

    for category in "${cats[@]}"; do
        # kind and the yq path under the category, separated by a space
        for spec in \
            'pkg .universal' "pkg .${OS}" \
            'cargo .cargo' "cargo .\"cargo-${OS}\"" \
            'script .scripts.universal' "script .scripts.${OS}" \
            'npm .npm.universal' "npm .npm.${OS}"; do
            kind="${spec%% *}"
            path="${spec#* }"

            while read -r entry; do
                [[ -n "${entry}" ]] || continue
                checked=$((checked + 1))
                status=0
                check_entry "${kind}" "${entry}" || status=$?
                case "${status}" in
                    0) ;;
                    2)
                        skipped=$((skipped + 1))
                        echo "skip     ${category}: ${entry} (${kind}, can't be checked here)"
                        ;;
                    *)
                        missing=$((missing + 1))
                        echo "MISSING  ${category}: ${entry} (${kind})"
                        FAILED+=("${category}: ${entry} not found (${kind})")
                        ;;
                esac
            done < <(entries "${category}" "${path}")
        done
    done

    echo "checked ${checked}: $((checked - missing - skipped)) found, ${missing} missing, ${skipped} skipped"
}

# Checks that every command in packages.yml's `commands` lists runs from a
# fresh interactive zsh, which is the shell the tools get used in. A command
# that exists in this process but not in zsh is reported on its own, because
# it points at a PATH problem rather than a failed install.
function verify_commands() {
    local -a wanted=()
    local category cmd found
    for category in "${cats[@]}"; do
        while read -r cmd; do
            [[ -n "${cmd}" ]] && wanted+=("${cmd}")
        done < <(yq ".commands.${category} | [.universal, .${OS}] | .[][]" "${PACKAGE_LIST}" | tr -d '"')
    done

    if [[ ${#wanted[@]} -eq 0 ]]; then
        return 0
    fi

    found=''
    if command -v zsh &> /dev/null; then
        # The probe exits with the status of its last command, and grep exits
        # 1 on no match, so `|| true` keeps a missing tool from ending the run
        # under pipefail before it can be reported.
        # -i reads ~/.zshrc, which sets PATH. The marker keeps prompt and
        # plugin output from being mistaken for a result, and it is matched
        # anywhere in a line because vim-mode prints a cursor escape code
        # ahead of the first one.
        found="$(zsh -ic 'for c in "$@"; do command -v "$c" >/dev/null 2>&1 && echo "FOUND:$c"; done' _ "${wanted[@]}" </dev/null 2>/dev/null | grep -o 'FOUND:[^[:space:]]*' | sed 's/^FOUND://')" || true
    fi

    local ok=0
    for cmd in "${wanted[@]}"; do
        if grep -qx -- "${cmd}" <<< "${found}"; then
            # Being on PATH is not being installed: a binary can load none of
            # its libraries after an OS upgrade. Skip a command only zsh sees.
            if command -v "${cmd}" &> /dev/null && ! probe_command "${cmd}"; then
                echo "BROKEN   ${cmd} (found, but fails every version flag)"
                FAILED+=("verify: ${cmd} is on your PATH but does not run")
            else
                ok=$((ok + 1))
            fi
        elif command -v "${cmd}" &> /dev/null; then
            echo "NOT ON ZSH PATH  ${cmd} ($(command -v "${cmd}"))"
            FAILED+=("verify: ${cmd} is installed but not on your zsh PATH")
        else
            echo "MISSING  ${cmd}"
            FAILED+=("verify: ${cmd} is not installed")
        fi
    done
    echo "verified ${#wanted[@]} commands: ${ok} found in zsh"
    verify_rust
}

# Runs a command with each common version flag and succeeds when one works.
# No single flag fits every tool: tmux wants -V, unzip wants -v, and
# actionlint wants -version. A command that fails all of them is broken, or
# stuck, and the timeout keeps a stuck one from hanging the run.
#
# Arguments
# $1: command name
function probe_command() {
    local cmd="${1}"
    local flag limit=''
    if command -v timeout &> /dev/null; then
        limit='timeout 10'
    elif command -v gtimeout &> /dev/null; then
        limit='gtimeout 10'
    fi

    for flag in --version -V -v version -version; do
        # stdin and output are closed so a tool that starts a screen exits.
        # shellcheck disable=SC2086
        if ${limit} "${cmd}" "${flag}" </dev/null &> /dev/null; then
            return 0
        fi
    done
    return 1
}

# Warns when the Rust toolchain is old, and lists toolchains besides stable.
# The weekly update in rust.zsh and the update in bootstrap() keep stable
# current, so an old one means both have stopped working. Extra toolchains are
# listed and never removed: a project's rust-toolchain.toml may pin one.
function verify_rust() {
    command -v rustc &> /dev/null || return 0

    local built age_days built_epoch
    built="$(rustc --version | grep -o '[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}' | tail -1)" || true
    if [[ -n "${built}" ]]; then
        # GNU date takes -d, BSD date on macOS takes -j -f.
        built_epoch="$(date -d "${built}" +%s 2>/dev/null || date -j -f '%Y-%m-%d' "${built}" +%s 2>/dev/null)" || true
        if [[ -n "${built_epoch}" ]]; then
            age_days=$(( ($(date +%s) - built_epoch) / 86400 ))
            if [[ ${age_days} -gt 90 ]]; then
                echo "OLD RUST  $(rustc --version) is ${age_days} days old"
                FAILED+=("verify: rustc is ${age_days} days old, run 'rustup update stable'")
            fi
        fi
    fi

    if command -v rustup &> /dev/null; then
        local extra
        extra="$(rustup toolchain list | grep -v '^stable' || true)"
        if [[ -n "${extra}" ]]; then
            echo "note: toolchains besides stable (not removed):"
            echo "${extra}" | sed 's/^/  /'
        fi
    fi
}

function install_all() {
    for category in "${cats[@]}"; do
        while read -r pkg; do
            # Keep package installers from consuming the remaining package list.
            attempt "${category}" pkg_install "${pkg//\"/}"
        done < <(yq ".packages.${category} | [.universal, .${OS}] | .[][]" "${PACKAGE_LIST}");

        # Install Rust cargo binaries. The cargo-<os> key is for crates that
        # one package manager has no prebuilt package for.
        while read -r pkg; do
            attempt "${category}" cargo_install "${pkg//\"/}"
        done < <(yq ".packages.${category} | [.cargo, .\"cargo-${OS}\"] | .[][]" "${PACKAGE_LIST}")

        # Install tools that ship their own curl-piped install script
        while read -r script; do
            attempt "${category}" script_install "${script//\"/}"
        done < <(yq ".packages.${category}.scripts | [.universal, .${OS}] | .[][]" "${PACKAGE_LIST}")

        # Install global npm packages. node comes from the package lists above
        # on macOS, and from nvm in bootstrap() on WSL2 Debian.
        while read -r pkg; do
            attempt "${category}" npm_install "${pkg//\"/}"
        done < <(yq ".packages.${category}.npm | [.universal, .${OS}] | .[][]" "${PACKAGE_LIST}")
    done
}

print_usage() {
    echo "Usage: ${SCRIPT} [-h|--help] [-d|-c|-v] [${CATEGORIES[*]}]"
}

print_help() {
    print_usage
    echo ""
    echo "    Description:"
    echo "        Bootstraps the local machine with minimal development tools and"
    echo "        installs all the packages specified by the given categories."
    echo ""
    echo "    Categories:"
    echo "        ${CATEGORIES[*]}"
    echo ""
    echo "    Options:"
    echo "        --help | -h"
    echo "            Prints this menu"
    echo "        -d"
    echo "            Dry run. Echoes the commands which would be executed to "
    echo "            stdout but doesn't modify anything."
    echo "        -c"
    echo "            Check. Confirms every package, crate and install script"
    echo "            URL for the given categories exists on this OS, without"
    echo "            installing anything. Run it after editing packages.yml."
    echo "        -v"
    echo "            Verify. Confirms the commands listed under \`commands\` in"
    echo "            packages.yml run from a fresh interactive zsh. An install"
    echo "            runs this itself when it finishes."
    echo ""
    echo "    A failed install step is reported at the end instead of ending"
    echo "    the run, and the exit status is then 1."
    exit 1
}


###############################################################################
# ENTRY POINT
###############################################################################

# The unusual syntax (versus `main "${@}"`) is a workaround for a bug in some
# non-POSIX compliant versions of bash in which $@ is reported as unbound.
#
main "${@:+$@}"

