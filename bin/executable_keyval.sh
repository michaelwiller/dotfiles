#!/bin/bash
#

TMPFILE=/tmp/.utm.$$
FILE="$1"; shift
ACTION=$1; shift

getkey(){
	cat $FILE | grep $1 | cut -d ':' -f 2
}

rmkey(){
	cat $FILE | grep -ve "^$1:" > $TMPFILE
	mv $TMPFILE  $FILE
}

setkey(){
	echo "$1:$2" >> $FILE
}

case $ACTION in

	set)
		rmkey $1
		setkey $1 $2
		;;

	get)
		getkey $1
		;;

	rm)
		rmkey $1
		;;
esac
