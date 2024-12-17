
action=$1
[ -z $1 ] && action=start
case $action in
	start)
		podman machine start
		kind delete cluster
		kind create cluster --config ~/bin/configs/kind/four-workers.yaml 
		;;
	stop)
		kind delete cluster
		podman machine stop
		;;
esac
