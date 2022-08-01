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
# The format is 'link name' -> 'destination' where destination is relative
# to the dots folder.
#
# TODO: some files are only relvant for arch. Split into different lists
declare -a FILES=(
  "${HOME}/.zshrc                                -> zsh/rc"
  "${HOME}/.config/zsh.d                         -> zsh/zsh.d"
  "${HOME}/.gitconfig                            -> git/gitconfig"
  "${HOME}/.gitignore_global                     -> git/gitignore_global"
  "${HOME}/.tigrc                                -> git/tigrc"
  "${HOME}/.config/nvim/init.lua                 -> nvim/init.lua"
  "${HOME}/.config/nvim/lua/plugins.lua          -> nvim/plugins.lua"
  "${HOME}/.tmux.conf                            -> tmux/tmux.conf"
  "${HOME}/.config/kitty/kitty.conf              -> tty/kitty.conf"
  "${HOME}/.config/kitty/themes/catppuccin.conf  -> tty/kitty-catppuccin.conf"
  "${HOME}/.config/kitty/arch.conf               -> tty/kitty-arch.conf"
  "${HOME}/.config/kitty/darwin.conf             -> tty/kitty-darwin.conf"
  "${HOME}/.cargo/config                         -> rust/cargo-config"
  "${HOME}/.config/bat/conifg                    -> bat/config"
  "${HOME}/.config/bat/themes/catppuccin.tmTheme -> bat/catppuccin.tmTheme"
  "${HOME}/.config/starship.toml                 -> starship/starship.toml"
  "${HOME}/.config/ranger/rc.conf                -> ranger/rc.conf"
  "${HOME}/.taskrc                               -> task/taskrc"
  "${HOME}/.timewarrior/timewarrior.cfg          -> timewarrior/timewarrior.cfg"
  "${HOME}/bin                                   -> bin"
  "${HOME}/wallpapers                            -> wallpapers"
)

declare -a FILES_ARCH=(
  "${HOME}/.config/hypr/hyprland.conf             -> hyprland/hyprland.conf"
  "${HOME}/.config/waybar/config                  -> waybar/config"
  "${HOME}/.config/waybar/style.css               -> waybar/style.css"
  "${HOME}/.config/swaylock/config                -> swaylock/config"
  "${HOME}/.config/rofi/config.rasi               -> rofi/config.rasi"
  "${HOME}/.config/rofi/catppuccin-mocha.rasi     -> rofi/catppuccin-mocha.rasi"
  "${HOME}/.config/gtk-3.0/settings.ini           -> gtk/gtk-3.0/settings.ini"
  "${HOME}/.config/gtk-4.0/settings.ini           -> gtk/gtk-4.0/settings.ini"
  "${HOME}/.config/systemd/user/dropbox.service   -> systemd/dropbox.service"
  "${HOME}/.config/cava/config                    -> cava/config"
  "${HOME}/.config/systemd/user/ssh-agent.service -> systemd/ssh-agent.service"
)

declare -a TEMPLATE_LINKS=(
  "${HOME}/.config/kitty/os.conf -> ${HOME}/.config/kitty/<OS>.conf"
)


################################################################################
# CONSTANTS
################################################################################

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
SCRIPT=$(basename "${0}")
OS="$(detect-os)"

################################################################################
# MAIN
################################################################################

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
                list_link_names
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

    link_files "${FILES[@]}"
    link_templates

    case "${OS}" in
        'arch')
            link_files "${FILES_ARCH[@]}"
            ;;
        *)
            ;;
    esac

    if [[ "${created_links}" == 'false' ]]; then
        echo "no changes required"
    fi
}


################################################################################
# FUNCTIONS
################################################################################

print_usage() {
    echo "Usage: ${SCRIPT} [-h|--help] [-f] [-d] [-l]"
}

print_help() {
    print_usage
    echo ""
    echo "    Description:"
    echo "        Bootstraps all my config files by linking all the config"
    echo "        files in this repo to their usual destination in the system."
    echo ""
    echo "    Options:"
    echo "        --help | -h"
    echo "            Prints this menu"
    echo "        -d"
    echo "            Dry run. Echoes the commands which would be executed to"
    echo "            stdout but doesn't modify anything."
    echo "        -f"
    echo "            Force. Overwrites any existing files."
    echo "        -l"
    echo "            Lists the files that would be installed by this program."
    echo "            Each full path is printed on a new line making the output"
    echo "            suitable for piping to xargs or using as a for-loop"
    echo "            input, i.e.:"
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
list_link_names() {
    for mapping in "${FILES[@]}"; do
        link_name "${mapping}"
    done
}

# Returns the link source from a 'link-target -> link-name' mapping
# in the $FILES array.
#
# - Argument $1: Mapping string, i.e. 'link-target -> link-name'
#
link_target() {
    echo "$1" | awk 'BEGIN { FS = " +-> +" } END { print $2 }'
}

# Returns the link name portion from a 'link-target -> link-name' mapping
# in the $FILES array.
#
# - Argument $1: Mapping string, i.e. 'link-target -> link-name'
link_name() {
    echo "$1" | awk 'BEGIN { FS = " +-> +" } END { print $1 }'
}

# Sets up symlinks for each file in $FILES. If the destination directory
# doesn't exist, it is created. If the destination file already exists,
# no action is taken.
#
# $1: A bash array of files in 'link_name -> target' form.
link_files() {
    local target
    local name
    for mapping in "$@"; do
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
        target="${template_target//<OS>/$OS}"

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

################################################################################
# ENTRY POINT
################################################################################

# The unusual syntax (versus `main "${@}"`) is a workaround for a bug in some
# non-POSIX compliant versions of bash in which $@ is reported as unbound.
#
main "${@:+$@}"

