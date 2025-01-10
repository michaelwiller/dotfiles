#!env bash

#############################################################
# 
#     GENERICS
#
#############################################################

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

alias gw="./gradlew"
alias g="gradle"

alias cls="tput clear"

alias la='ls -a | grep "\..*"'
alias lla='ls -la | grep "\..*"'
alias lsa='ls -a'
alias lsd='ls -l | grep "^[ld]"'
alias lsf='ls -l | grep "^[-l]"'
alias lsda='ls -la | grep "^[ld]"'
alias lsfa='ls -la | grep "^[-l]"'

# start: https://opensource.com/article/19/7/bash-aliases
alias ls='ls -F'
alias ll='ls -lh'

# if $darwin; then
#   alias lt='du -sh * | sort -h'
#   alias mnt="mount | awk -F' ' '{ printf \"%s\t%s\n\",\$1,\$3; }' | column -t | egrep ^/dev/ | sort"
# else
#   alias mnt='mount | grep -E ^/dev | column -t'
#   alias lt='ls --human-readable --size -1 -S --classify'
# fi

alias gh='history|grep'
alias count='find . -type f | wc -l'

alias pve='python3 -m venv ./venv'
alias pva='source ./venv/bin/activate'

alias gitroot='cd `git rev-parse --show-toplevel`'
# end

alias fav=". ~/bin/fav"
alias gg=". ~/bin/gg"
alias ggp=". ~/bin/gg -p"
alias ggh=". ~/bin/gg -h"
alias ggl=". ~/bin/gg -l"
alias ggf=". ~/bin/gg -f"
alias aws-profile=". ~/bin/aws-profile"
alias tool-version=". ~/bin/tool-version"

if which podman > /dev/null 2>&1; then
  alias docker=podman
  export KIND_EXPERIMENTAL_PROVIDER=podman
fi

# VIM 
if which nvim >> /dev/null; then
  export EDITOR=nvim
fi
alias vi=$EDITOR
alias vim=$EDITOR

# Chezmoi
alias cm="chezmoi"
complete -o default -o nospace -F __start_chezmoi chezmoi
