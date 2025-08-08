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

# Parse command-line options
while [[ "$1" =~ ^- ]]; do
    case "$1" in
        -r|--dry-run)
            dry_run=true
            shift
            ;;
        -d|--debug)
            debug=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done


if [ -z $1 ]; then
	actions="tpa vagrant"
else
	actions="$*"
	shift
fi

$debug && echo "Dry run: $dry_run, actions: $actions"

$dry_run && echo "Stopping run" && exit 1

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
