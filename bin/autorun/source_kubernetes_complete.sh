#!env bash

if which kubectl >/dev/null 2>&1; then

	source <(kubectl completion bash)
	alias k=kubectl
	complete -o default -F __start_kubectl k
	alias kx='f() { [ "$1" ] && kubectl config use-context $1 || kubectl config current-context ; } ; f'
	alias kn='f() { [ "$1" ] && kubectl config set-context --current --namespace $1 || kubectl config view --minify | grep namespace | cut -d" " -f6 ; } ; f'
	alias kbash='f() { kubectl run -it temp-shell --rm -i --tty --image ubuntu -- bash ; } ; f'
fi

if which oc >/dev/null 2>&1; then
	echo oc available
	source <(oc completion bash)
fi
