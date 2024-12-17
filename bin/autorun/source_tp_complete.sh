_tp_complete() {
	local cur prev opts fav_options
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	#
	#  The basic options we'll complete.
	#
	fav_options="commit copy demo deploy down list provision rmlogs reset setup ssh status up xp xp-default"

	opts=$fav_options

	#
	#  Complete the arguments to some of the basic commands.
	#
	case "${prev}" in

		ssh|xp)
			opts=$(tp __ls ${curr})
			;;

		*)
			;;
	esac

	COMPREPLY=($(compgen -W "${opts}" -- ${cur}))  
	return 0
}
complete -F _tp_complete tp
