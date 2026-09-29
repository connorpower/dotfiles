## Work machines only
##
## Enable with: touch ~/.config/zsh.d/enable-work

#---------------------------------------------------------------------- env ---

# graft sends anonymous usage stats to events.nanonets.com on a daily flush.
# DO_NOT_TRACK is a cross-tool convention, so this silences any other tool
# here that honors it. `graft telemetry` reports the state it sees.
export DO_NOT_TRACK=1

# Homebrew keeps libpq keg-only, so it links nothing into the prefix. Point
# the linker at the lib directory for crates that bind to it, such as sqlx.
if [[ "${OS}" == 'darwin' ]] && command -v brew &> /dev/null; then
    export PQ_LIB_DIR="$(brew --prefix libpq)/lib"
fi

# fvm is a macOS-only package here. ~/fvm/default appears once
# `fvm global <version>` selects a Flutter SDK.
if [[ "${OS}" == 'darwin' ]]; then
    export PATH="${HOME}/fvm/default/bin:${PATH}"
fi
