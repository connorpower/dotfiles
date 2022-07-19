## Ditto only

#----------------------------------------------------------------- Rust Core ---

# File descriptor-hungry DB tests
ulimit -n 4096

#--------------------------------------------------------------------- HyDRA ---

export QUAY_USER='connorpowerditto'
export DITTO_LICENSE=$(cat ~/.ditto/license)
export KAFKA_BOOTSTRAP_HOST=localhost:9092

#------------------------------------------------------------- SDK/FFI Tools ---

path_append "${HOME}/.dotnet/tools"

export ANDROID_SDK_ROOT="${HOME}/Library/Android/sdk"

eval "$(rbenv init -)"

export NVM_DIR="$HOME/.nvm"
if [[ -s "/usr/local/opt/nvm/nvm.sh" ]]; then
    source "/usr/local/opt/nvm/nvm.sh"
fi
if [[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ]]; then
    source "/usr/local/opt/nvm/etc/bash_completion.d/nvm"
fi

#----------------------------------------------------------------- Aliases ---

alias cdddev='cd "${SCM_DIR}/ditto/ditto"'
alias cddno='cd "${SCM_DIR}/personal/notes/ditto"'

