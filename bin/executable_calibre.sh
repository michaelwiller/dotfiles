#!/usr/bin/env bash

targetdir="$HOME/personal/20 Books/20.90 Calibre Backups"
sourcedir="$HOME/Calibre Library"
keep=4
fmt=day


usage(){
	echo "$0 backup"
	echo "   $0 backup"
	echo "      create tar-ball in icloud 20.90"
	echo "      Keep $keep tar-balls"
}


case $1 in
	backup)
		backup.sh -s "$sourcedir" -d "$targetdir" -k $keep -f $fmt 2>&1 | while IFS= read -r line; do
			echo "  $line"
		done
		;;

	*|help)
		usage
		exit
		;;
esac
