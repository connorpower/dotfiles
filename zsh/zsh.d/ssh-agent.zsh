# Export vars for an already running ssh-agent, or start a new one if
# necessary.
function connect-ssh-agent() {
    # Try to detect an already running ssh agent.
    if ! ssh-add -l &>/dev/null; then
        # If another agent has saved info, try to load it's ENV vars
        if [[ -r ~/.ssh-agent ]]; then
            eval "$(cat ~/.ssh-agent)" > /dev/null
        fi

    # Try to detect a running agent (again). We might still not have
    # one as the process which wrote the .ssh_agent file might be gone.
        if ! ssh-add -l &>/dev/null; then
            (umask 066; ssh-agent > ~/.ssh-agent)
            eval "$(<~/.ssh-agent)" >/dev/null
        fi
    fi
}

connect-ssh-agent
