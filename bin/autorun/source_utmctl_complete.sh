_utmctl() {
	local cur prev opts fav_options
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	#
	#  The basic options we'll complete.
	#
	fav_options="edit copy-file connect help list refresh-local-env remove set-port stop"
	opts=$fav_options

	#
	#  Complete the arguments to some of the basic commands.
	#
	case "${prev}" in

		edit|help|ls|list)
			opts=""
			;;

		copy-file|\
		ssh|connect|\
		init|\
		refresh-local-env|\
		remove|\
		set-port|\
		stop)
			opts=$(utmctl _names ${curr})
			;;

		-f)
			opts=$(ls)
			;;
			
		*)
			;;
	esac

	COMPREPLY=($(compgen -W "${opts}" -- ${cur}))  
	return 0
}
complete -F _utmctl utmctl
