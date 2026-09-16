## Work machines only
##
## Enable with: touch ~/.config/zsh.d/enable-work

#---------------------------------------------------------------------- env ---

# Homebrew keeps libpq keg-only, so it links nothing into the prefix. Point
# the linker at the lib directory for crates that bind to it, such as sqlx.
if [[ "${OS}" == 'darwin' ]] && command -v brew &> /dev/null; then
    export PQ_LIB_DIR="$(brew --prefix libpq)/lib"
fi
