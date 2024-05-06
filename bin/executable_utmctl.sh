#!/bin/bash

CONFIG_FILE=$HOME/.local/.utmctl.config
COMMAND=$0

usage(){
	echo "$0"
	echo "   rm NAME"
	echo "          Remove server:port with name NAME"
	echo "   sp NAME PORT"
	echo "          Set port to PORT on server of NAME"
}
getPort(){
	cat $CONFIG_FILE | grep $1 | cut -d ':' -f 2
}

removeServer(){
	local name=$1
	cat $CONFIG_FILE | grep -v "$name:" > /tmp/$$
	mv /tmp/$$  $CONFIG_FILE
}
setPort(){
	local name=$1
	local port=$2
	removeServer $name
	echo "$name:$port" >> $CONFIG_FILE
}

mkdir -p $(dirname $CONFIG_FILE)
touch $CONFIG_FILE
action=$1; shift
case $action in

	rm) 
		removeServer $1
		;;

	ssh)
		p=$(getPort $1)
		if [ "$p" == "" ]; then
			echo "Port not found: $1"
			exit 0
		fi
		ssh -p $p utm@127.0.0.1
		;;

	sp)
		setPort $1 $2
		;;
	ls)
		if [ -z $1 ]; then
			cat $CONFIG_FILE
		else
			grep "$1" $CONFIG_FILE
		fi
		;;
	help)
		usage
		;;

	*)
		usage
esac
