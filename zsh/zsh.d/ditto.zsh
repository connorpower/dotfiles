## Ditto only

#----------------------------------------------------------------------- Nix ---

eval "$(direnv hook zsh)"

#----------------------------------------------------------------- Rust Core ---

# File descriptor-hungry DB tests
ulimit -n 4096

if [[ -f ~/.ditto/license ]]; then
    license=$(cat ~/.ditto/license)
    export DITTO_LICENSE="${license}"
else
    echo "WARNING: Add a ditto test license to ~/.ditto/license"
fi

#--------------------------------------------------------------------- HyDRA ---

export QUAY_USER='connorpowerditto'

#-------------------------------------------------------- SDK Language Tools ---

# Managed with nix now
#path_append "${HOME}/.dotnet/tools"
# eval "$(rbenv init -)"

export NVM_DIR="$HOME/.nvm"
if [[ -s "/usr/local/opt/nvm/nvm.sh" ]]; then
    source "/usr/local/opt/nvm/nvm.sh"
fi
if [[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ]]; then
    source "/usr/local/opt/nvm/etc/bash_completion.d/nvm"
fi

#------------------------------------------------------------------- Aliases ---

export ddev="${SCM_DIR}/ditto/ditto"
export dno="${HOME}/Ditto/notes"
export repl="${SCM_DIR}/ditto/ditto/core/replication"

alias rmddata='rm -rf target/debug/ditto_data'
