## Ditto only

#----------------------------------------------------------------- Rust Core ---

# File descriptor-hungry DB tests
ulimit -n 4096

#--------------------------------------------------------------------- HyDRA ---

export QUAY_USER='connorpowerditto'

if [[ -f ~/.ditto/license ]]; then
    license=$(cat ~/.ditto/license)
    export DITTO_LICENSE="${license}"
else
    echo "WARNING: Add a ditto test license to ~/.ditto/license"
fi

export KAFKA_BOOTSTRAP_HOST=localhost:9092

#----------------------------------------------------------------------- Nix ---

eval "$(direnv hook zsh)"

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

export ddev="${SCM_DIR}/ditto/ditto"
export dno="${HOME}/Ditto/notes"
export repl="${SCM_DIR}/ditto/ditto/core/replication"

