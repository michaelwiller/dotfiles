info(){
	echo "------------------------------------------------------------------"
	echo " $1"
	echo "------------------------------------------------------------------"
	sleep 2
}

destroy-all-tpa(){

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

	for a in $(find . -type d -depth 1); do
		echo '----------------------------------'
		echo "$a:"
		echo '----------------------------------'
		(cd $a; vagrant destroy -f)
	done
}

cd ~/clusters

info "TPA clusters"
(cd tpa; destroy-all-tpa)

info "Vagrant clusters"
(cd vagrant; destroy-all-vagrant)
