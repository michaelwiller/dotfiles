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
	echo "  ssh [NAME]"
	echo "          ssh to utm@localhost:PORT, using the PORT saved on the NAME"
}

keyval(){
	keyval.sh $CONFIG_FILE $*
}


mkdir -p $(dirname $CONFIG_FILE)
touch $CONFIG_FILE
action=$1; shift
case $action in

	help)
		usage
		;;

	ls)
		keyval ls "$1"
		;;
	rm) 
		keyval rm $1
		;;

	sp)
		keyval set $1 $2
		;;
		
	ssh)
		p=$(keyval get $1)
		if [ "$p" == "" ]; then
			echo "Port not found for: $1"
			exit 0
		fi
		ssh -p $p utm@127.0.0.1
		;;

	*)
		usage
esac
