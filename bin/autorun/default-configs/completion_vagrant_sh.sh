_vagrantsh_complete() {
	local cur prev opts fav_options
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	#
	#  The basic options we'll complete.
	#
	fav_options="id key forward ssh up down"

	opts=$fav_options

	#
	#  Complete the arguments to some of the basic commands.
	#
	case "${prev}" in

		*)
			;;
	esac

	COMPREPLY=($(compgen -W "${opts}" -- ${cur}))  
	return 0
}

complete -F _vagrantsh_complete vagrant.sh

# Vagrant.sh
alias v=vagrant.sh
complete -o default -o nospace -F _vagrantsh_complete v
