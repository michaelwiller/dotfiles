_fav() {
	local cur prev opts fav_options
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	#
	#  The basic options we'll complete.
	#
	fav_options="-a -d -e -g -l -h -?"
	opts=$fav_options

	if [ $COMP_CWORD -gt 2 ]; then
		return 0;  # were done
	fi

	case "${cur}" in
		-*)
			COMPREPLY=($(compgen -W "${fav_options}" -- ${cur}))  
			return 0
			;;
	esac

	#
	#  Complete the arguments to some of the basic commands.
	#
	case "${prev}" in
	-a)
			#opts=$(javautil References favorites -x)
			opts=$(references.pl favorites -x)
			;;
		-d)
			#opts=$(javautil References favorites -x)
			opts=$(references.pl favorites -x)
			;;
	-e)
			return 0
			;;
	-l)
			return 0
			;;
	-h|-?)
			return 0
			;;
		*)
			#opts="$(javautil References favorites -x)"
			opts=$(references.pl favorites -x)
			;;
	esac

	COMPREPLY=($(compgen -W "${opts}" -- ${cur}))  
	return 0
}
_gg() 
{
	local cur prev opts gg_options
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	#
	#  The basic options we'll complete.
	#
	gg_options="-h -f -l -? -p"
	opts=$gg_options

	if [ $COMP_CWORD -gt 2 ]; then
		return 0;  # were done
	fi

	case "${cur}" in
		-*)
			COMPREPLY=($(compgen -W "${gg_options}" -- ${cur}))  
			return 0
			;;
	esac

	#
	#  Complete the arguments to some of the basic commands.
	#
	case "${prev}" in
		-f)
			#opts=$(javautil References favorites -x)
			opts=$(references.pl favorites -x)
			;;
		*)
			return 0
			;;
	esac

	COMPREPLY=($(compgen -W "${opts}" -- ${cur}))  
	return 0
}
_ggf(){
	local cur opts
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	#opts=$(javautil References favorites -x)
	opts=$(references.pl favorites -x)
	COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
	return 0;
}
complete -F _fav fav
complete -o dirnames -F _gg gg
complete -o dirnames -F _ggf ggf

