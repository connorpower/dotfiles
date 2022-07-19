# Sitting. Set a 20 min timer before transitioning to stand.
# http://ergo.human.cornell.edu/CUESitStand.html
sit() {
    timer_announce $(( 20 * 60 )) "Time to stand up"
}

# Standing. Set an 8 min timer before transitioning to walking around a bit.
# http://ergo.human.cornell.edu/CUESitStand.html
stand() {
    timer_announce $(( 8 * 60 )) "Time to walk around a bit"
}

# Walking. Set a 2 min timer before transitioning to sitting.
# http://ergo.human.cornell.edu/CUESitStand.html
walk() {
    timer_announce $(( 2 * 60 )) "Time to sit down"
    # Start a stop watch to keep track of time away
    sw
}

# Play an announcement and display a message after a timer (seconds) elapses.
# A countdown will display while the timer is running.
#
# Arguments
# ---------
# $1: duration (secs)
# $2: terminal message
timer_announce() {
    if [[ $# -ne 2 ]]; then
        echo "usage: timer_announce duration msg" >&2
        return 1
    fi

    # Start a countdown timer
    timeout "${1}" sw 2>/dev/null # todo: countdown based on $1, not a stopwatch

    # Replce timer text with msg
    printf "\033[2K\r%s\n" "${2}"

    case "${OS}" in
        'darwin')
            say "${2}"
            ;;
        'arch')
            echo "TODO..." >&2
            ;;
        *)
            echo "unsupported OS" >&2
        ;;
    esac

}
