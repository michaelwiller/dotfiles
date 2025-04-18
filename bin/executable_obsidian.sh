#!/usr/bin/env bash
CONFIG_FILE=~/.config/obsidian-sh.conf
dry_run=false
debug=false

usage(){
    echo "Usage: obsidian.sh [options] [command] [arguments]"
    echo ""
    echo "Options:"
    echo "  -r, --dry-run        Perform a dry run without making changes."
    echo "  -d, --debug          Enable debug mode to print additional information."
    echo ""
    echo "Commands:"
    echo "  backup               Backup all configured Obsidian vaults."
    echo "  mvref <old> <new>    Update all references of 'old' to 'new' in markdown files."
    echo "                       Optionally, specify a directory to limit the scope."
    echo "  help                 Show this help message."
    echo ""
    echo "Examples:"
    echo "  obsidian.sh backup"
    echo "  obsidian.sh mvref 'Old Link' 'New Link' /path/to/vault"
}

# List available sections in the config file
list_sections() {
  awk '/^\[.*\]$/ { gsub(/[\[\]]/, "", $0); print $0 }' "$CONFIG_FILE"
}

# Function to read vaults from the config file
# It reads the specified section (e.g., example1, example2) and prints the lines.
# The section should contain lines like:
# source=~/obsidian/vault/example1
# backup=~/obsidian/backup/example1
# These are evaluated to set the source and backup variables.
read_section() {
  local section=$1
  awk -v section="[$section]" '
    $0 == section { in_section=1; next }
    /^\[/ { in_section=0 }
    in_section && $0 !~ /^#/ && $0 !~ /^\s*$/ { print $0 }
  ' "$CONFIG_FILE"
}

update_links() {
  local old_link="$1"
  local new_link="$2"
  local dir="${3:-.}"  # Default to current directory

  find "$dir" -type f -name "*.md" -print0 | while IFS= read -r -d '' file; do
    if grep -q "\[\[$old_link\]\]" "$file"; then
	    echo Updating: $file
      sed -i '' "s|\[\[$old_link\]\]|\[\[$new_link\]\]|g" "$file"
      echo "Updated: $file"
    fi
  done

  echo "Updated all occurrences of [[${old_link}]] to [[${new_link}]] in .md files under $dir"
}


# Not used
handle_dual(){
	IFS=

	for dualfile in $(ls *\ 2.md)
	do
    		original_file=$(echo $dualfile | sed 's/ 2.md/.md/')
    		if ! diff $dualfile $original_file > /dev/null 2>&1
    		then
			mv $dualfile $original_file
    		else
			rm $dualfile
    		fi
	done
}


backup_all(){

	backup_vault(){
    # $1 = vault name
    while IFS= read -r line; do
        echo "line:$line"
        local key
        local value
        key=$(echo "$line" | cut -d '=' -f 1)
        value=$(echo "$line" | cut -d '=' -f 2-)
        case "$key" in
            source)
                source=$(eval echo "$value")
                ;;
            backup)
                backup=$(eval echo "$value")
                ;;
            *)
                echo "  Unknown key: $key"
                return 1
                ;;
        esac
    done < <(read_section "$1") 

    echo "  source: \"$source\""
    echo "  backup: \"$backup\""

    if [ ! -d "$source" ]; then
        echo "  Source directory $source does not exist"
        return 1
    fi

    if [ ! -d "$backup" ]; then
        echo "  Backup directory $backup does not exist"
        return 1
    fi

    echo "  call backup.sh -s \"$source\" -d \"$backup\""
    if $dry_run; then
        echo "    (Dry run mode, not executing backup)"
        return 0
    fi
    backup.sh -s "$source" -d "$backup" 2>&1 | while IFS= read -r line; do
        echo "    $line"
    done
	}

	echo "Backing up all configured vaults..."

	for section in $(list_sections); do
		echo "Backing up: $section"
		backup_vault "$section" | while IFS= read -r line; do
			echo "  $line"
		done
		echo ""
	done
}

create_config_template() {
  echo "Creating configuration file template at $CONFIG_FILE..."
  mkdir -p "$(dirname "$CONFIG_FILE")"  # Ensure the directory exists
  cat > "$CONFIG_FILE" <<EOF
# ~/.config/clusters.conf
# Configuration file for obsidian vaults

[example1]
# Example:
# source=~/obisidian/vault/example1
# backup=~/obsidian/vault/example1

[example2]
# Example:
# source=~/obisidian/vault/example2
# backup=~/obsidian/vault/example2

EOF
}

# Parse command-line options
while [[ "$1" =~ ^- ]]; do
    case "$1" in
        -r|--dry-run)
            dry_run=true
            shift
            ;;
        -d|--debug)
            debug=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Enable debug mode if requested
if $debug; then
    echo "Debug mode enabled."
    set -x
fi

if [ ! -f "$CONFIG_FILE" ]; then
  create_config_template
  echo "Template created. Please edit $CONFIG_FILE to add your clusters."
  exit 0
fi


case $1 in
	backup)
		backup_all
		;;

	mvref)
		shift
		if [[ -z "$1" || -z "$2" ]]; then
			echo "Usage:$0 mvref 'SOME OLD LINK' 'SOME OTHER LINK' [directory]"
			exit -1
		fi
		update_links "$1" "$2" "."
		;;
	*|help)
		usage
		exit
		;;
esac
