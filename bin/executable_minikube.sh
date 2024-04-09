
case $1 in 

	start)
		export PATH="/opt/homebrew/opt/socket_vmnet/bin:$PATH"
		sudo brew services start socket_vmnet
		minikube start --driver qemu --network socket_vmnet
		;;
	stop)
		minikube stop
		;;

	pause)
		minikube pause
		;;
	*)
		echo "$0 start|stop|pause"
		;;
esac
