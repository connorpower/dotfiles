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
  'tty/kitty.conf              -> ~/.config/kitty/kitty.conf'
  'tty/kitty-catppuccin.conf   -> ~/.config/kitty/themes/catppuccin.conf'
  'tty/kitty-arch.conf         -> ~/.config/kitty/arch.conf'
  'tty/kitty-darwin.conf       -> ~/.config/kitty/darwin.conf'
  'rust/cargo-config           -> ~/.cargo/config'
  'starship/starship.toml      -> ~/.config/starship.toml'
  'wm/hyprland.conf            -> ~/.config/hypr/hyprland.conf'
  'bin                         -> ~/bin'
  'wallpapers                  -> ~/wallpapers'
)

declare -a TEMPLATE_LINKS=(
  "${HOME}/.config/kitty/<OS>.conf   -> ~/.config/kitty/os.conf"
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

    created_links='false'

    link_files
    link_templates

    if [[ "${created_links}" == 'false' ]]; then
        echo "no changes required"
    fi
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
        link_name "${mapping}"
    done
}

# Returns the file source from a 'link-target -> link-name' mapping
# in the $FILES array.
#
# - Argument $1: Mapping string, i.e. 'link-target -> link-name'
#
link_target() {
    echo "$1" | awk 'BEGIN { FS = " +-> +" } END { print $1 }'
}

# Returns the file destination from a 'link-target -> link-name' mapping
# in the $FILES array.
#
# - Argument $1: Mapping string, i.e. 'link-target -> link-name'
link_name() {
    link_name=$(echo "$1" | awk 'BEGIN { FS = " +-> +" } END { print $2 }')
    echo "${link_name/#\~/$HOME}"
}

# Sets up symlinks for each file in $FILES. If the destination directory
# doesn't exist, it is created. If the destination file already exists,
# no action is taken.
link_files() {
    local target
    local name
    for mapping in "${FILES[@]}"; do
        target=$(link_target "${mapping}")
        name=$(link_name "${mapping}")

        make_link "${DIR}/${target}" "${name}"
    done

}

link_templates() {
    local template_target
    local target
    local name
    for mapping in "${TEMPLATE_LINKS[@]}"; do
        template_target=$(link_target "${mapping}")
        target=$(echo "${template_target}" | sed "s/<OS>/${OS}/g")

        name=$(link_name "${mapping}")

        make_link "${target}" "${name}"
    done
}

# $1 src
# $2 dst
make_link() {
    local target
    local name
    local name_dir_path

    target=$(realpath "${1}")
    name="${2}"
    name_dir_path=$(dirname "${name}")

    if [[ ! -e "${target}" ]]; then
        echo "${target} doesn't exist" 1>&2
        exit 1
    fi

    if [[ -d "${target}" && -d "${name}" ]]; then
        # ${1} is a directory and already exists — skipping
        return 0
    fi

    if [[ "${force}" == 'true' ]] || [[ ! -e "${name}" ]]; then
        if [[ ! -d "${name_dir_path}" ]]; then
            $dry_run mkdir -p "${name_dir_path}"
        fi
        $dry_run ln -fs "${target}" "${name}"
        created_links='true'
    fi
}

###############################################################################
# ENTRY POINT
###############################################################################

# The unusual syntax (versus `main "${@}"`) is a workaround for a bug in some
# non-POSIX compliant versions of bash in which $@ is reported as unbound.
#
main "${@:+$@}"

