#!/usr/bin/env bash
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
