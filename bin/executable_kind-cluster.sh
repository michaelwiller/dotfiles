#!/usr/bin/env bash

start_docker(){
	if which podman; then
		podman machine start
	fi
}


action=$1
[ -z $1 ] && action=start
case $action in
	start)
		start_docker		
		kind delete cluster
		kind create cluster --config ~/bin/configs/kind/four-workers.yaml 
		;;
	stop)
		kind delete cluster
		podman machine stop
		;;
esac
