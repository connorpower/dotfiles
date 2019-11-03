#!/bin/bash

set -e

###############################################################################
## Constants
###############################################################################

readonly FILES=(\
  gitconfig \
  gitignore_global \
  tigrc \
  vimrc \
  zshrc \
  utils \
)

###############################################################################
## Constants
###############################################################################

main() {
    local dry_run='false';

    while getopts ":hdl" o; do
        case "${o}" in
            h)
                usage "$@"
                return 0
                ;;
            d)
                dry_run='true'
                ;;
            l)
                list_files
                return 0
                ;;
            *)
                usage "$@"
                return 1
                ;;
        esac
    done
    shift $((OPTIND-1))

    if [ "${1}" = "help" ] || [ "${1}" = "--help" ]; then
        usage
        return 0
    fi

    link_files "${dry_run}"
}

###############################################################################
## Functions
###############################################################################

usage() {
    echo "Usage: $0 [-h|--help] [-d] [-l]" 1>&2
    echo "    --help | -h"
    echo "        Prints this menu"
    echo "    -d"
    echo "        Dry run. Echoes the commands which would be executed to "
    echo "        stdout but doesn't modify anything."
    echo "    -l"
    echo "        Lists the files that would be installed by this program with"
    echo "        each full path file on a new line making the output suitable"
    echo "        for piping to xargs or using as a for-loop input, i.e:"
    echo ""
    echo "            for file in \$($0 -l); do"
    echo "                ls -lah \"\$file\";"
    echo "            done"
    exit 1
}

list_files() {
    for file in "${FILES[@]}"; do
        echo "${HOME}/.${file}"
    done
}

link_files() {
    local dry_run="${1}"

    for file in "${FILES[@]}"; do
        if [[ ! -e "${file}" ]]; then
            echo "${file} doesn't exist" 1>&2
            return 1
        fi

        local target="${HOME}/.${file}"
        if [[ ! -e "${target}" ]]; then
            if [[ "${dry_run}" == 'true' ]]; then
                echo ln -s "${PWD}/${file}" "${target}"
            else
                     ln -s "${PWD}/${file}" "${target}"
            fi
        fi
    done
}

###############################################################################
## Entry Point
###############################################################################

main "${@}"
