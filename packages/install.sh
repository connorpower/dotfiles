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
OS="$(detect-os)"
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

            pkg_install yq
            brew tap homebrew/cask-fonts
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

}

# Install a package with the os-specific package manager
#
# Arguments
# $1: package name (required)
# $2: repo info (optional, eg 'aur' on arch)
function pkg_install() {
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
        *)
            exit 1 # unreachable
            ;;
    esac
}

function cargo_install() {
    ${dry_run} cargo install --locked "${1}"
}

function install_all() {
    for category in "${cats[@]}"; do
        while read -r pkg; do
            pkg_install "${pkg//\"/}"
        done < <(yq ".packages.${category} | [.universal, .${OS}] | .[][]" "${PACKAGE_LIST}");

        # If we're on arch, also install AUR packages
        if [[ "${OS}" == 'arch' ]]; then
            while read -r pkg; do
                pkg_install "${pkg//\"/}" 'arch-aur'
            done < <(yq ".packages.${category} | [.\"arch-aur\"] | .[][]" "${PACKAGE_LIST}")
        fi

        # Install Rust cargo binaries
        while read -r pkg; do
            cargo_install "${pkg//\"/}"
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

