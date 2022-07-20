#!/usr/bin/env bash

# Fail fast and fail early.
#   - Abort script at first error
#   - Attempts to use undefined variable outputs error message and exits
#   - Pipelines return the exit status of the last command in the pipe to fail
#
set -euo pipefail


###############################################################################
# CONFIGURATION
###############################################################################

# EDIT ME:
# This is the only part of the script which needs to be customized once a new
# file is added.
#
# The format is 'source file' -> 'destination'.
# 'source-file' is the file path in this repository. 'destination' is the
# location which should be linked to 'source-file' when the script is run.
#
declare -a FILES=(
  'zsh/rc                      -> ~/.zshrc'
  'zsh/zsh.d                   -> ~/.config/zsh.d'
  'git/gitconfig               -> ~/.gitconfig'
  'git/gitignore_global        -> ~/.gitignore_global'
  'git/tigrc                   -> ~/.tigrc'
  'nvim/init.lua               -> ~/.config/nvim/init.lua'
  'nvim/plugins.lua            -> ~/.config/nvim/lua/plugins.lua'
  'tmux/tmux.conf              -> ~/.tmux.conf'
  'tty/kitty.conf              -> ~/.config/kitty/kity.conf'
  'rust/cargo-config           -> ~/.cargo/config'
  'starship/starship.toml      -> ~/.config/starship.toml'
  'bin                         -> ~/bin'
)


###############################################################################
# CONSTANTS
###############################################################################

_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
readonly DIR="${_dir}"
unset _dir

_script=$(basename "${0}")
readonly SCRIPT="${_script}"
unset _script


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

    dry_run=''
    force='false'

    while getopts ":hfdl" o; do
        case "${o}" in
            h)
                print_help
                return 0
                ;;
            f)
                force='true'
                ;;
            d)
                dry_run='echo'
                ;;
            l)
                list_destinations
                return 0
                ;;
            *)
                print_usage >&2
                return 1
                ;;
        esac
    done
    shift $((OPTIND-1))

    link_files
}


###############################################################################
# FUNCTIONS
###############################################################################

print_usage() {
    echo "Usage: ${SCRIPT} [-h|--help] [-f] [-d] [-l]"
}

print_help() {
    print_usage
    echo ""
    echo "    Description:"
    echo "        Bootstraps all my config files by linking all the config files in"
    echo "        this repo to their usual destination in the system. Using symlinks"
    echo "        like this is useful because when I update a config file, either in"
    echo "        the repo or where it's being linked to, the file will be updated"
    echo "        everywhere."
    echo ""
    echo "    Options:"
    echo "        --help | -h"
    echo "            Prints this menu"
    echo "        -d"
    echo "            Dry run. Echoes the commands which would be executed to "
    echo "            stdout but doesn't modify anything."
    echo "        -f"
    echo "            Force. Overwrites any existing files."
    echo "        -l"
    echo "            Lists the files that would be installed by this program. Each"
    echo "            full path is printed on a new line making the output suitable"
    echo "            for piping to xargs or using as a for-loop input, i.e.:"
    echo ""
    echo "                for file in \$(${SCRIPT} -l); do"
    echo "                    ls -lah \"\$file\""
    echo "                done"
}

# Lists all file destinations in the format:
#
#     /Users/username/.gitconfig
#     /Users/username/.gitignore_global
#     /Users/username/.tigrc
#     /Users/username/.vimrc
#     ...
#
list_destinations() {
    for mapping in "${FILES[@]}"; do
        file_dest "${mapping}"
    done
}

# Returns the file source from a 'file-source -> file-destination' mapping
# in the $FILES array.
#
# - Argument $1: Mapping string, i.e. 'file-source -> file-destination'
# - Returns: 'file-source'
#
file_source() {
    echo "$1" | awk 'BEGIN { FS = " +-> +" } END { print $1 }'
}

# Returns the file destination from a 'file-source -> file-destination' mapping
# in the $FILES array.
#
# - Argument $1: Mapping string, i.e. 'file-source -> file-destination'
# - Returns: 'file-destination'
#
file_dest() {
    dest=$(echo "$1" | awk 'BEGIN { FS = " +-> +" } END { print $2 }')
    echo "${dest/#\~/$HOME}"
}

# Sets up symlinks for each file in $FILES. If the destination directory
# doesn't exist, it is created. If the destination file already exists,
# no action is taken.
#
link_files() {
    # Keeps track of whether any links were created or not.
    local created_links='false'

    local file
    local fq_src
    local fq_dest
    local dest_dir
    for mapping in "${FILES[@]}"; do
        file=$(file_source "${mapping}")
        fq_src="${DIR}/${file}"
        fq_dest=$(file_dest "${mapping}")
        dest_dir=$(dirname "${fq_dest}")

        if [[ ! -e "${fq_src}" ]]; then
            echo "${fq_src} doesn't exist" 1>&2
            exit 1
        fi

        if [[ -d "${fq_src}" && -d "${fq_dest}" ]]; then
            echo "${fq_dest} is a directory and already exists — skipping ${file}"
            continue
        fi

        if [[ "${force}" == 'true' ]] || [[ ! -e "${fq_dest}" ]]; then
            if [[ ! -d "${dest_dir}" ]]; then
                $dry_run mkdir -p "${dest_dir}"
            fi
            $dry_run ln -fs "${fq_src}" "${fq_dest}"
            created_links='true'
        fi
    done

    if [[ "${created_links}" == 'false' ]]; then
        echo "no changes required"
    fi
}


###############################################################################
# ENTRY POINT
###############################################################################

# The unusual syntax (versus `main "${@}"`) is a workaround for a bug in some
# non-POSIX compliant versions of bash in which $@ is reported as unbound.
#
main "${@:+$@}"

