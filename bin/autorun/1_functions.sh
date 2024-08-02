#!env bash

pyact(){
	venv=${1:-"venv"}
	echo $venv
	if [ ! -d $venv ]; then
		echo "Could not activate venv: $venv. Are you in the right directory?"
	else
		source $venv/bin/activate
	fi
}

__parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ git:\1/'
}

__pathadd() {
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
