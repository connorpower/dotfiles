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

_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
readonly DIR="${_dir}"
unset _dir

_script=$(basename "${0}")
readonly SCRIPT="${_script}"
unset _script

readonly PACKAGE_LIST="${DIR}/packages.yml"

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

    cats=$@

    ${dry_run} sudo -v
    bootstrap
    install
}


###############################################################################
# FUNCTIONS
###############################################################################

function bootstrap() {
    if [[ "$(uname | tr '[A-Z]' '[a-z]')" == 'darwin' ]]; then 
            ${dry_run} xcode-select --install || true

            if ! command -v brew &> /dev/null; then
                ${dry_run} /bin/bash -c "$(${dry_run} curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi

            ${dry_run} brew install yq
    elif uname -r | grep --quiet arch; then
            sudo pacman -Syy
            sudo pacman --needed --noconfirm -S yq git base-devel

            # AUR support
            if ! command -v yay &> /dev/null; then
                git clone https://aur.archlinux.org/yay.git /tmp/install-yay
                cd /tmp/install-yay
                makepkg --noconfirm -si
                cd -
                rm -rf /tmp/install-yay
            fi
    else
            echo 'Unknown OS' >&2
            print_usage
            exit 1
    fi
}

function install() {
    local pkgmanager=''
    local os=''
    if [[ "$(uname | tr '[A-Z]' '[a-z]')" == 'darwin' ]]; then 
            os='darwin'
            pkgmanager='brew install'
    elif uname -r | grep --quiet arch; then
            os='arch'
            pkgmanager='sudo pacman --needed --noconfirm -S'
    else
            echo 'Unknown OS' >&2
            print_usage
            exit 1
    fi

    for category in $cats; do
        for pkg in $(yq ".packages.${category} | [.universal, .${os}] | .[][]" "${PACKAGE_LIST}"); do
            ${dry_run} ${pkgmanager} ${pkg//\"/}
        done
    done
}

print_usage() {
    echo "Usage: ${SCRIPT} [-h|--help] [${CATEGORIES[@]}]"
}

print_help() {
    print_usage
    echo ""
    echo "    Description:"
    echo "        Bootstraps the local machine with minimal development tools and"
    echo "        installs all the packages specified by the given categories."
    echo ""
    echo "    Categories:"
    echo "        ${CATEGORIES[@]}"
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

