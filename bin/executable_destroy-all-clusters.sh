info(){
	echo "------------------------------------------------------------------"
	echo " $1"
	echo "------------------------------------------------------------------"
	sleep 2
}

destroy-all-tpa(){
	info "TPA clusters"
	cd ~/clusters/tpa

	for a in $(find . -type d -depth 1);
	do
		echo '----------------------------------'
		echo "$a:"
		echo '----------------------------------'
		if [ -e $a/ssh_config ]; then
 			(cd $a; tpaexec deprovision .)
		else
			echo 'Cluster not running'
		fi
	done
}


destroy-all-vagrant(){

	info "VAGRANT clusters"
	cd ~/clusters/vagrant

	for a in $(find . -type d -depth 1); do
		echo '----------------------------------'
		echo "$a:"
		echo '----------------------------------'
		(cd $a; vagrant destroy -f)
	done
}

action=$1

case $action in
	tpa)
		destroy-all-tpa
		;;

	vagrant)
		destroy-all-vagrant
		;;
	*)
		destroy-all-tpa
		destroy-all-vagrant
		;;
esac

