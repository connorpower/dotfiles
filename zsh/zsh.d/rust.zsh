# cargo()
# ------------------------
# Updates the stable Rust toolchain at most once a week, the first time cargo
# runs after that. A shell that never runs cargo pays nothing, which is why this
# wraps cargo and does not run at startup. `rustup default stable` selects the
# channel and never updates it, and a new crate release can need a newer
# compiler than the one installed.
#
# packages/install.sh updates the toolchain too and writes the same stamp file,
# so a fresh install does not update again on the first cargo call.
#
#     $ DOTFILES_NO_RUST_UPDATE=1 cargo build    # skip the update this once
#     $ DOTFILES_RUST_UPDATE_DAYS=14             # change the interval
#
cargo() {
    local stamp="${XDG_STATE_HOME:-${HOME}/.local/state}/rust-toolchain-updated"
    local days="${DOTFILES_RUST_UPDATE_DAYS:-7}"
    local -a recent

    # `cargo +nightly ...` asks for another toolchain, so stable is beside the point.
    if [[ -z "${DOTFILES_NO_RUST_UPDATE:-}" && "${1:-}" != +* ]] \
        && command -v rustup &> /dev/null; then
        # The glob qualifier matches the file only if it changed within $days.
        recent=(${stamp}(N.md-${days}))
        if (( ${#recent} == 0 )); then
            echo "cargo: stable toolchain not updated for ${days} days, updating (DOTFILES_NO_RUST_UPDATE=1 skips this)" >&2
            if rustup update stable >&2; then
                mkdir -p "${stamp:h}" && touch "${stamp}"
            else
                echo "cargo: toolchain update failed, carrying on with the installed one" >&2
            fi
        fi
    fi

    command cargo "$@"
}
