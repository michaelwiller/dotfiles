#!env bash

parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ git:\1/'
}

pathadd() {
  local do_prefix=false
  if [ "$1" == "-p" ]; then
    do_prefix=true;
    shift
  fi

	if ! echo $PATH | grep "$1" > /dev/null; then
    if $do_prefix; then
      export PATH=$1:$PATH
    else
      export PATH=$PATH:$1
    fi
	fi
}
debugOut() {
	if $debug ; then
		errout "$*"
	fi;
}

die(){
	echo "$*"
	exit 0
}

out(){
	echo "$*" 1>&2
}

stdout(){
	echo "$*"
}

errout(){
	echo "$*" 1>&2
}
