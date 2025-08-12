#!/usr/bin/env bash

source ~/bin/autorun/1_functions.sh

source_dir(){
  local env_count
  local source_dir="$1"
  local search_pattern="${2}*"
  
  if [ -d $source_dir ]; then
    env_count=$(find $source_dir -type f -name "$search_pattern" | wc -l)
  else
    env_count=0
  fi
  [ $env_count -gt 0 ] && for a in $(find $source_dir -type f -name "$search_pattern" -maxdepth 1); do
    source $a
  done
}



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


source_dir $HOME/.config/bash-local-env
source_dir $HOME/bin/autorun "source_"

[ -f /usr/local/etc/bash_completion ] && source /usr/local/etc/bash_completion

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

export PS1="\e[0m\e[${ps1Color}m\u@\h \w\[\e[0m\] $(__k8s_context__) \$(__parse_git_branch) \n\$ "

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
else
    echo "TMUX disabled"
fi
echo;echo
