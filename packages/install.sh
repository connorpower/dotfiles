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
    'ditto'
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

    while getopts ":hd" o; do
        case "${o}" in
            h)
                print_help
                return 0
                ;;
            d)
                dry_run='echo'
                ;;
            *)
                print_usage >&2
                return 1
                ;;
        esac
    done
    shift $((OPTIND-1))

    cats=( "$@" )

    # Refresh sudo credentials in case we need it
    ${dry_run} sudo -v
    bootstrap
    install_all
    configure
}


###############################################################################
# FUNCTIONS
###############################################################################

function bootstrap() {
    case "${OS}" in
        'darwin')
            xcode-select -p &>/dev/null || ${dry_run} xcode-select --install

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
            ;;
        'arch')
            ${dry_run} sudo pacman -Syy
            pkg_install yq
            pkg_install git
            pkg_install base-devel

            # AUR support
            if ! command -v yay &> /dev/null; then
                ${dry_run} git clone https://aur.archlinux.org/yay.git /tmp/install-yay
                ${dry_run} cd /tmp/install-yay
                ${dry_run} makepkg --noconfirm -si
                ${dry_run} cd -
                ${dry_run} rm -rf /tmp/install-yay
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
	    # nvm
	    if [ ! -s "${HOME}/.nvm/nvm.sh" ]; then
	        ${dry_run} curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
	    fi
	    # shellcheck source=/dev/null
	    source "${HOME}/.nvm/nvm.sh"
	    if ! nvm ls --no-colors 2>/dev/null | grep -q 'lts'; then
	        ${dry_run} nvm install --lts
	    fi
	    ;;
        *)
            echo 'Unknown OS' >&2
            print_usage
            exit 1
            ;;
    esac

    if ! command -v rustup &> /dev/null; then
        ${dry_run} /bin/bash -c \
            "$(${dry_run} curl \
                --proto '=https' \
                --tlsv1.2 \
                -sSf https://sh.rustup.rs \
            )"
    fi
    # Make cargo available in the current session if rustup just installed it
    # shellcheck source=/dev/null
    [ -s "${HOME}/.cargo/env" ] && source "${HOME}/.cargo/env"
}

# Install a package with the os-specific package manager
#
# Arguments
# $1: package name (required)
# $2: repo info (optional, eg 'aur' on arch)
function pkg_install() (
    echo "installing ${1}..."
    case "${OS}" in
        'darwin')
            # Don't quote "$1" to allow parsing args like "--cask cask-name"
            ${dry_run} brew install $1
            ;;
        'arch')
            if [[ "${2:-}" == 'arch-aur' ]]; then
                # Never run with sudo for AUR packages
                ${dry_run} yay --needed --aur -S "${1}"
            else
                ${dry_run} sudo pacman --needed --noconfirm -S "${1}"
            fi
            ;;
	'debian')
	    ${dry_run} sudo apt-get install -y "${1}"
	    ;;
        *)
            exit 1 # unreachable
            ;;
    esac
)

function cargo_install() {
    ${dry_run} cargo install --locked "${1}"
}

function configure() {
    # aws-cli v2: not available via apt, requires unzip (installed via packages.yml)
    if [[ "${OS}" == 'debian' ]] && ! command -v aws &> /dev/null; then
        ARCH=$(uname -m)
        ${dry_run} curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip" -o /tmp/awscliv2.zip
        ${dry_run} unzip -q /tmp/awscliv2.zip -d /tmp
        ${dry_run} sudo /tmp/aws/install
        ${dry_run} rm -rf /tmp/aws /tmp/awscliv2.zip
    fi

    case "${OS}" in
        'debian'|'arch')
            if [[ "${SHELL}" != "$(command -v zsh)" ]]; then
                ${dry_run} sudo usermod -s "$(command -v zsh)" "${USER}"
                echo "Default shell changed to zsh — takes effect on next login"
            fi
            ;;
    esac

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

function install_all() {
    for category in "${cats[@]}"; do
        while read -r pkg; do
            # Keep package installers from consuming the remaining package list.
            (pkg_install "${pkg//\"/}") </dev/null
        done < <(yq ".packages.${category} | [.universal, .${OS}] | .[][]" "${PACKAGE_LIST}");

        # If we're on arch, also install AUR packages
        if [[ "${OS}" == 'arch' ]]; then
            while read -r pkg; do
                (pkg_install "${pkg//\"/}" 'arch-aur') </dev/null
            done < <(yq ".packages.${category} | [.\"arch-aur\"] | .[][]" "${PACKAGE_LIST}")
        fi

        # Install Rust cargo binaries
        while read -r pkg; do
            (cargo_install "${pkg//\"/}") </dev/null
        done < <(yq ".packages.${category} | [.cargo] | .[][]" "${PACKAGE_LIST}")
    done
}

print_usage() {
    echo "Usage: ${SCRIPT} [-h|--help] [${CATEGORIES[*]}]"
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
    exit 1
}


###############################################################################
# ENTRY POINT
###############################################################################

# The unusual syntax (versus `main "${@}"`) is a workaround for a bug in some
# non-POSIX compliant versions of bash in which $@ is reported as unbound.
#
main "${@:+$@}"

