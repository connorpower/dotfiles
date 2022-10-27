# Named directory for directx project
export dx="${SCM_DIR}/personal/directx"

# Re-export the Windows Optional Component SSH ahead of everything else so
# the system's ssh-agent is available for key storage.
export PATH="/c/Windows/System32/OpenSSH:${PATH}"
