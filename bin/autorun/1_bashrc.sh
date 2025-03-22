#!/usr/bin/env bash

source ~/bin/autorun/1_functions.sh

for a in $(ls ~/.config/bash-local-env/*); do
  source $a
done

#__showpath

__pathadd /opt/homebrew/bin
__pathadd /opt/homebrew/sbin
__pathadd /usr/local/bin
__pathadd /usr/bin
__pathadd /bin
__pathadd /usr/sbin
__pathadd /sbin

__pathadd ~/bin
__pathadd ~/.local/bin

#__showpath

[ -f /usr/local/etc/bash_completion ] && source /usr/local/etc/bash_completion
for a in $(ls ~/bin/autorun/source_*); do
  source $a
done

set -o vi 

if [ -z $sessionStage ]; then
    sessionStage=dev
fi
case $sessionStage in 
    dev|development|local)
        ps1Color=32 # Green
        ;;
    stage|staging)
        ps1Color=95 # Light Magenta
        ;;
    prod|production)
        ps1Color=31 # Red
        ;;
esac

export PS1="\e[0m\e[${ps1Color}m\u@\h \w\[\e[0m\] \$(__parse_git_branch) \n\$ "

# # Add taskwarrior count to prompt
# if which task >>/dev/null; then
#   export PS1="inbox:\$(task +in +PENDING count) $PS1"
#   . $DIR/taskwarrior-configs
# fi

if $TMUX_ENABLED; then
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
fi
