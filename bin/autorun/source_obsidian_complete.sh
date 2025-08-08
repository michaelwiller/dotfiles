# Tab-completion for obsidian.sh
_obsidian_completions() {
  local cur prev commands sections
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  # Define the available commands
  commands="-r --dry-run -d --debug -h --help backup mvref replace help"

  # Check the previous word to determine context
  case "$prev" in
    obsidian.sh)
      # Complete the main commands
      COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
      ;;
    replace)
      # Complete with placeholder for old/new links or directory
      if [[ "$COMP_CWORD" -eq 2 ]]; then
        COMPREPLY=( $(compgen -W "<old_text>" -- "$cur") )
      elif [[ "$COMP_CWORD" -eq 3 ]]; then
        COMPREPLY=( $(compgen -W "<new_text>" -- "$cur") )
      else
        COMPREPLY=( $(compgen -d -- "$cur") )  # Suggest directories
      fi
      ;;
    mvref)
      # Complete with placeholder for old/new links or directory
      if [[ "$COMP_CWORD" -eq 2 ]]; then
        COMPREPLY=( $(compgen -W "<old_link>" -- "$cur") )
      elif [[ "$COMP_CWORD" -eq 3 ]]; then
        COMPREPLY=( $(compgen -W "<new_link>" -- "$cur") )
      else
        COMPREPLY=( $(compgen -d -- "$cur") )  # Suggest directories
      fi
      ;;
    backup)
      # Complete with sections from the config file
      if [ -f ~/.config/obsidian-sh.conf ]; then
        sections=$(awk '/^\[.*\]$/ { gsub(/[\[\]]/, "", $0); print $0 }' ~/.config/obsidian-sh.conf)
        COMPREPLY=( $(compgen -W "$sections" -- "$cur") )
      fi
      ;;
    *)
      # Default to file and directory completion
      COMPREPLY=( $(compgen -f -- "$cur") )
      ;;
  esac
}

# Register the completion function for obsidian.sh
complete -F _obsidian_completions obsidian.sh
