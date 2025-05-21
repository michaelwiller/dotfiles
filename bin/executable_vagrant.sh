#!/usr/bin/env bash

action=$1
shift

get-ips(){
	vagrant ssh -c "ip a | grep inet | grep -v inet6"
}
get-key(){
	vagrant ssh-config | grep IdentityFile | sed 's/^ *//' | cut -f 2 -d ' '
}

forward-port(){
	destination=$1
	if [ $destination = "--help" ]; then
		echo "forward arguments: destination localport [vmport [vm_forward]]"
		echo "   destination   - The IP of the vagrant vm"
		echo "   localport     - The port used on the host"
		echo "   vmport        - The port used on the vm (defaults to localport)"
		echo "   vm_forward    - IP address to forward inside the VM (defaults to localhost)"
		exit 0
	fi
	localport=$2
	vmport=${3:-$localport}
	vm_forward=${4:-localhost}
	key=$(get-key)

	ssh -i ${key} -L ${localport}:${vm_forward}:${vmport} vagrant@${destination}
}

case $action in
	up)
		vagrant up
		;;
	down)
		vagrant halt -f
		;;
	ssh)
		vagrant ssh $*
		;;
	ip)
		get-ips
		;;
	key)
		get-key
		;;
	forward) 
		forward-port $*
		;;
	*)
		help
		;;
esac
