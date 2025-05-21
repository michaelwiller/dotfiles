info(){
	echo "------------------------------------------------------------------"
	echo " $1"
	echo "------------------------------------------------------------------"
	sleep 2
}

destroy-all-tpa(){
	info "TPA clusters"
	cd ~/clusters/tpa

	for a in $(ls);
	do
		if [ ! -e $a/config.yml ]; then
			continue
		fi
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
		cd $a;
		vagrant status | grep "is running" > /dev/null 2>&1
		is_running=$?
		cd ..;
		if [ $is_running -eq 0 ]; then
			cd $a; vagrant halt -f; cd ..
		else
			echo 'Cluster not running'
			continue
		fi
	done
}

actions="$*"
[ -z $1 ] && actions="tpa vagrant"

echo $actions | for action in $(cat --); do

	case $action in

		tpa)
			destroy-all-tpa
			;;

		vagrant)
			destroy-all-vagrant
			;;

	esac

done
