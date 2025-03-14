#!/usr/bin/env bash


usage(){
	echo "$0 mvref|backup"
	echo "   mvref:"
	echo "   $0 mvref OLDREF NEWREF"
	echo "      note: must be in vault-directory - does not recurse"
	echo " "
	echo "   backup:"
	echo "   $0 backup"
	echo "      will look for folders in \~/icloudlinks/obsidian-vaults"
	echo "      all folder will have a tar-ball created in \~/icloudlinks/obsidian-backups (subfolder of same name as vault)"
	echo "      7 tar-balls are retained per vault"
}


update_links() {
  local old_link="$1"
  local new_link="$2"
  local dir="${3:-.}"  # Default to current directory

	if [[ -z "$old_link" || -z "$new_link" ]]; then
		echo "Usage: update_links 'SOME OLD LINK' 'SOME OTHER LINK' [directory]"
		return 1
  fi

  find "$dir" -type f -name "*.md" -print0 | while IFS= read -r -d '' file; do
    if grep -q "\[\[$old_link\]\]" "$file"; then
	    echo Updating: $file
      sed -i '' "s|\[\[$old_link\]\]|\[\[$new_link\]\]|g" "$file"
      echo "Updated: $file"
    fi
  done

  echo "Updated all occurrences of [[${old_link}]] to [[${new_link}]] in .md files under $dir"
}


# Not used
handle_dual(){
	IFS=

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

backup_all(){
	cd ~
	backup_vault EDB $1
	backup_vault Cabinet $1
}

case $1 in
	backup)
		backup_all
		;;

	mvref)
		shift
		update_links "$1" "$2" "."
		;;
	*|help)
		usage
		exit
		;;
esac
