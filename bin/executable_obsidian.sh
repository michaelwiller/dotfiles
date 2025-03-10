#!/usr/bin/env bash


# Not used
handle_dual(){
	IFS='
'

	for dualfile in $(ls *\ 2.md)
	do
    		original_file=$(echo $dualfile | sed 's/ 2.md/.md/')
    		if ! diff $dualfile $original_file > /dev/null 2>&1
    		then
			mv $dualfile $original_file
    		else
			rm $dualfile
    		fi
	done
}

backup_vault(){
	targetdir=~/icloudlinks/obsidian-backups/$1
	sourcedir=~/icloudlinks/obsidian-vaults/$1
	
	echo "$1:"
	[ ! -e $sourcedir ] && echo "  $sourcedir does not exist" && return;
	[ ! -e $targetdir ] && echo "  $targetdir does not exist" && return;
	if [ ! "$2" == "list" ]; then backup.sh $sourcedir $targetdir; fi
	latest_backup=$(ls -Ht $targetdir | head -n 1)
	oldest_backup=$(ls -Htr $targetdir | head -n 1)
	count_backup=$(ls -Htr $targetdir | wc -l)
	echo "  Backups: $count_backup ($oldest_backup - $latest_backup)"	
}

backup(){
	cd ~
	backup EDB $1
	backup Cabinet $1
}


case $1 in
	backup)
		backup
		;;

	mvref)
		move_reference "$1" "$2"
		;;
	*)
		printf "\n $*\n\nI have not idea what this means..."
		exit
		;;
esac
