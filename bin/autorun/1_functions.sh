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
	echo ''; return
	local ctx
	which kubectl >/dev/null 2>&1
	if [ $? -gt 0 ]; then
		echo ""
		return
	fi
	ctx="$(kubectl config current-context 2>/dev/stderr)"
	if [ -z $ctx ]; then
		echo ""
  else
    echo "k8s:$ctx"
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

__source_dir(){
  local env_count
  local source_dir="$1"
  local search_pattern="${2}*"
  
  if [ -d $source_dir ]; then
    env_count=$(find $source_dir -type f -name "$search_pattern" | wc -l)
  else
    env_count=0
  fi
  [ $env_count -gt 0 ] && for a in $(find $source_dir -type f -name "$search_pattern" -maxdepth 1 | grep -v .DS_Store); do
    source $a
  done
}
