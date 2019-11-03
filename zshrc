################################################################################
# LANGUAGE
################################################################################

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LESSCHARSET=UTF-8


################################################################################
# ZSH CONFIGURATION
################################################################################

export ZSH="${HOME}/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(
  git
  osx
  colored-man-pages
  aws
)

unsetopt share_history
setopt no_share_history

bindkey "[D" backward-word
bindkey "[C" forward-word
bindkey "^[a" beginning-of-line
bindkey "^[e" end-of-line


################################################################################
# PATHS
################################################################################

export PATH=$PATH:"${HOME}/.fastlane/bin"
export PATH=$PATH:$(go env GOPATH)/bin
export PATH=$PATH:"${HOME}/Library/Python/3.7/bin"
export PATH="$HOME/.cargo/bin:$PATH"

################################################################################
# RUBY
################################################################################

eval "$(rbenv init -)"


################################################################################
# AWS
################################################################################

source "${HOME}/bin/aws-utils.sh"


################################################################################
# UTILITY FUNCTIONS
################################################################################

rfc_date() {
    if [[ ! -z "${1}" ]]; then
        # Expects input in form of `date +%s`
        date -u -r "${1}" +%Y-%m-%dT%H:%M:%SZ
    else
        date -u +%Y-%m-%dT%H:%M:%SZ
    fi
}


################################################################################
# ALIASES
################################################################################

DEVELOPER_DIR="${HOME}/Developer"

alias cddev="cd '${DEVELOPER_DIR}'"
alias o="open ."
alias ow="open ./*.xcworkspace"

alias gs="git status"
alias gitstats="git shortlog -sn"


################################################################################
# ZSH INITIALIZATION
################################################################################

source $ZSH/oh-my-zsh.sh
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
