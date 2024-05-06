#!/bin/bash

CONFIG_FILE=$HOME/.local/.utmctl.config
COMMAND=$0

usage(){
	echo "$0"
	echo "   rm NAME"
	echo "          Remove server:port with name NAME"
	echo "   sp NAME PORT"
	echo "          Set port to PORT on server of NAME"
	echo "   ls [TXT]"
	echo "          Search for TXT or list all content if no TXT"
}

keyval(){
	keyval.sh $CONFIG_FILE $*
}


mkdir -p $(dirname $CONFIG_FILE)
touch $CONFIG_FILE
action=$1; shift
case $action in

	rm) 
		keyval rm $1
		;;

	ssh)
		p=$(keyval get $1)
		if [ "$p" == "" ]; then
			echo "Port not found for: $1"
			exit 0
		fi
		ssh -p $p utm@127.0.0.1
		;;

	sp)
		keyval set $1 $2
		;;
	ls)
		keyval ls "$1"
		;;
	help)
		usage
		;;

	*)
		usage
esac
