bindkey -v
export KEYTIMEOUT=1

function cursor-mode-command() {
    echo -ne '\e[1 q' 
}

function cursor-mode-insert() {
    echo -ne '\e[5 q'
}

# Change cursor shape for different vi modes.
function zle-keymap-select {
    if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
        cursor-mode-command 
    elif [[ ${KEYMAP} == main ]] ||
         [[ ${KEYMAP} == viins ]] ||
         [[ ${KEYMAP} = '' ]] ||
         [[ $1 = 'beam' ]]; then
        cursor-mode-insert
    fi
}

function zle-line-init() {
    # Begin each new line in vim insert mode
    zle -K viins 
    cursor-mode-insert
}

preexec() {
    cursor-mode-insert
}

zle -N zle-keymap-select
zle -N zle-line-init

# Use beam shape cursor immediately on startup since the shell starts
# in insert mode
cursor-mode-insert
