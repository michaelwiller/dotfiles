# TMUX auto attach/start
_tmux=$(which tmux)
printf "TMUX: "
if [ -z $_tmux ]; then
    printf "not installed.\n"
else
    printf "looking for session.. "
    if $_tmux has-session; then
        if [ -z $TMUX ]; then
            printf "attaching.."
            $_tmux attach
        else
            printf "already active."
        fi
    else
        echo notmux: $NOTMUX
        if [ -z $NO_TMUX ]; then
            printf  "not found. Starting ..."
            tmux
        else
            printf "NOTMUX set ... not starting"
        fi
    fi
fi
