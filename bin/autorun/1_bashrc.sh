#!/usr/bin/env bash

export CONFIG_DIR=~/.config

source ~/bin/autorun/1_functions.sh



# Detect OS
export cygwin=false;
export darwin=false;
export linux=false;
export msys=false

case  $(uname | cut -c1-6) in
	Linux)
		export linux=true;
		;;
	Darwin) 
		export darwin=true;
		;;
	MINGW*) 
		export msys=true;
		;;
	CYGWIN)	
		export cygwin=true;
		;;
esac

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

__source_dir $HOME/bin/autorun/default-configs 
__source_dir $CONFIG_DIR/bash-local-env

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

export PS1="\e[0m\e[${ps1Color}m\u@\h \w\[\e[0m\] \$(__k8s_context__) \$(__parse_git_branch) \n\$ "

# # Add taskwarrior count to prompt
# if which task >>/dev/null; then
#   export PS1="inbox:\$(task +in +PENDING count) $PS1"
#   . $DIR/taskwarrior-configs
# fi

$TMUX_ENABLED && ~/bin/autorun/2_tmux_attach_or_start.sh

echo;echo
