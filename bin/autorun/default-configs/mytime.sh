#!/usr/bin/env bash

_mt_completions() {
    local cur prev opts aliases
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    # Core flags
    opts="-a -s -l -e -d stop"

    # If the previous word was -s, suggest aliases from the YAML file
    if [[ ${prev} == "-s" ]]; then
        # This python snippet extracts just the alias keys from your YAML
        aliases=$(python3 -c "import yaml, pathlib; p = pathlib.Path.home() / '.mytime_data.yaml'; print(' '.join(yaml.safe_load(p.read_text())['aliases'].keys()))" 2>/dev/null)
        COMPREPLY=( $(compgen -W "${aliases}" -- ${cur}) )
        return 0
    fi

    # Otherwise, suggest the main flags
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi
}

complete -F _mt_completions mt

alias mt='$HOME/.venv/homebin/bin/python3 $HOME/bin/mytime.py'
