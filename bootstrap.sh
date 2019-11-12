#!/bin/bash

set -e

###############################################################################
## Constants
###############################################################################

readonly DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
readonly SCRIPT=$(basename "${0}")

# An array of mappings for 'source file' -> 'destination'. This allows us to
# keep the dotfiles repository organized by topic independent of where the
# files ultimately need to be placed.
declare -a FILES=(\
  'git/gitconfig -> ~/.gitconfig' \
  'git/gitignore_global -> ~/.gitignore_global' \
  'git/tigrc -> ~/.tigrc' \
  'vim/vimrc -> ~/.vimrc' \
  'shell/zshrc -> ~/.zshrc' \
  'shell/tmux.conf -> ~/.tmux.conf' \
  'tty/alacritty/alacritty.yml -> ~/.config/alacritty/alacritty.yml' \
  'aws/aws-utils.sh -> ~/bin/aws-utils.sh' \
)

###############################################################################
## Constants
###############################################################################

main() {
    dry_run='false'
    force='false'

    while getopts ":hfdl" o; do
        case "${o}" in
            h)
                usage
                return 0
                ;;
            f)
                force='true'
                ;;
            d)
                dry_run='true'
                ;;
            l)
                list_destinations
                return 0
                ;;
            *)
                echo $(short_usage) >&2
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

short_usage() {
    echo "Usage: ${SCRIPT} [-h|--help] [-f] [-d] [-l]"
}

usage() {
    short_usage
    echo "    --help | -h"
    echo "        Prints this menu"
    echo "    -d"
    echo "        Dry run. Echoes the commands which would be executed to "
    echo "        stdout but doesn't modify anything."
    echo "    -f"
    echo "        Force. Overwrites any existing files"
    echo "    -l"
    echo "        Lists the files that would be installed by this program with"
    echo "        each full path file on a new line making the output suitable"
    echo "        for piping to xargs or using as a for-loop input, i.e:"
    echo ""
    echo "            for file in \$(${SCRIPT} -l); do"
    echo "                ls -lah \"\$file\";"
    echo "            done"
    exit 1
}

# Lists all file destinations in the format:
#
#     ~/.gitconfig
#     ~/.gitignore_global
#     ~/.tigrc
#     ~/.vimrc
#     ...
#
list_destinations() {
    for mapping in "${FILES[@]}"; do
        echo $(file_dest "${mapping}")
    done
}

# Returns the file source from a 'file-source -> file-destination' mapping
# in the $FILES array.
#
# - Argument $1: Mapping string, i.e. 'file-source -> file-destination'
# - Returns: 'file-source'
#
file_source() {
    echo "$1" | awk 'BEGIN { FS = " -> " } END { print $1 }'
}

# Returns the file destination from a 'file-source -> file-destination' mapping
# in the $FILES array.
#
# - Argument $1: Mapping string, i.e. 'file-source -> file-destination'
# - Returns: 'file-destination'
#
file_dest() {
    echo "$1" | awk 'BEGIN { FS = " -> " } END { print $2 }'
}

# Sets up symlinks for each file in $FILES. If the destination directory
# doesn't exist, it is created. If the destination file already exists,
# no action is taken.
#
link_files() {
    # Keeps track of whether any links were created or not.
    created_links='false'

    for mapping in "${FILES[@]}"; do
        local file=$(file_source "${mapping}")
        local dest=$(file_dest "${mapping}")

        local fq_file="${DIR}/${file}"
        local fq_dest="${dest/#\~/$HOME}"

        local dest_dir=$(dirname "${fq_dest}")

        if [[ ! -e "${fq_file}" ]]; then
            echo "${fq_file} doesn't exist" 1>&2
            return 1
        fi

        if [[ "${force}" == 'true' ]] || [[ ! -e "${fq_dest}" ]]; then
            if [[ "${dry_run}" == 'true' ]]; then
                if [[ ! -d "${dest_dir}" ]]; then
                    echo mkdir -p "${dest_dir}"
                fi
                echo ln -fs "${fq_file}" "${fq_dest}"
                created_links='true'
            else
                if [[ ! -d "${dest_dir}" ]]; then
                    mkdir -p "${dest_dir}"
                fi
                ln -fs "${fq_file}" "${fq_dest}"
                created_links='true'
            fi
        fi
    done

    if [[ "${dry_run}" == 'true' ]] && [[ "${created_links}" == 'false' ]]; then
        echo "no changes required"
    fi
}

###############################################################################
## Entry Point
###############################################################################

main "${@}"
