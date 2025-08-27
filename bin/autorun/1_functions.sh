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

__k8s_context__(){
   if which kubectl >>/dev/null; then
     echo "k8s:$(kubectl config current-context)"
   else
     echo ""
   fi
}

__parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ git:\1/'
}

__showpath() {
	echo PATH CONTENT:
	OIFS=$IFS
	IFS="
"
	for a in $(echo "${PATH}" | tr ':' '\n'); do
	  echo - $a
	done
	IFS="$OIFS"; unset OIFS
}

__pathadd() {
  local do_prefix=false
  if [ "$1" == "-p" ]; then
    do_prefix=true;
    shift
  fi

  if echo $PATH | grep "$1" >/dev/null 2>&1; then
		P2=$(echo "${PATH}" | tr ':' '\n' | grep -v -x -F "$1" | tr '\n' ':')
		PATH="$P2"; unset P2
  fi

  if $do_prefix; then
    export PATH=$1:$PATH
  else
    export PATH=$PATH:$1
  fi
}
