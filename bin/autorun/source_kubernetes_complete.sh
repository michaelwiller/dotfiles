#!env bash

if which kubectl >/dev/null 2>&1; then

	source <(kubectl completion bash)
	alias k=kubectl
	complete -o default -F __start_kubectl k
	alias kx='f() { [ "$1" ] && kubectl config use-context $1 || kubectl config current-context ; } ; f'
	alias kn='f() { [ "$1" ] && kubectl config set-context --current --namespace $1 || kubectl config view --minify | grep namespace | cut -d" " -f6 ; } ; f'
fi
