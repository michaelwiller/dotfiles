backup_obsidian=true
backup_calibre=true
destroy_all_clusters=true
shutdown=true
dry_run=false
debug=false 
sleep_time=5


perform_shutdown() {

  # Dry run mode
  if [[ "$dry_run" = "true" ]]; then
      echo "Dry run mode enabled. No changes will be made."
  fi 

  # Debug mode
  if [[ "$debug" = "true" ]]; then
      echo "Debug mode enabled. Commands will be printed."
      echo "Debugging information:"
      echo "  Destroy all clusters: $destroy_all_clusters"
      echo "  Backup Obsidian: $backup_obsidian"
      echo "  Backup Calibre: $backup_calibre"
      echo "  Shutdown: $shutdown"
      echo "  Dry run: $dry_run"
      echo "  Debug: $debug"
      echo "  Current user: $(whoami)"
      echo "  Current date: $(date)"
      echo "  Current time: $(date +%T)"
      echo "  Current working directory: $(pwd)"
  fi

  # Destroy all clusters
  if $destroy_all_clusters; then
    echo "Destroying all clusters..."
    ! $dry_run && destroy-all-clusters.sh | while IFS= read -r line; do
      echo "  $line"
    done
  else
    echo "Skipping cluster destruction."
  fi

  # Backup Obsidian and Calibre
  if $backup_obsidian; then
    echo "Backing up Obsidian..."
    ! $dry_run && obsidian.sh backup | while IFS= read -r line; do
      echo "  $line"
    done
  else
    echo "Skipping Obsidian backup."
  fi

  if $backup_calibre; then
    echo "Backing up Calibre..."
    ! $dry_run && calibre.sh backup | while IFS= read -r line; do
      echo "  $line"
    done
  else
    echo "Skipping Calibre backup."
  fi

  # Shutdown the system
  if $shutdown; then
    echo "Shutting down the system..."
    ! $dry_run && sleep $sleep_time
    ! $dry_run && sudo shutdown -h now
  else
    echo "Skipping system shutdown."
  fi

}



# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--no-destroy)
            destroy_all_clusters=false
            shift
            ;;
        -o|--no-obsidian)
            backup_obsidian=false
            shift
            ;;
        -c|--no-calibre)
            backup_calibre=false
            shift
            ;;
        -s|--no-shutdown)
            shutdown=false
            shift
            ;;
        -r|--dry-run)
            dry_run=true
            shift
            ;;
        -d|--debug)
            debug=true
            shift
            ;;
        -h|-?|--help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  -t, --no-destroy    Skip destroying all clusters"
            echo "  -o, --no-obsidian   Skip backing up Obsidian"
            echo "  -c, --no-calibre    Skip backing up Calibre"
            echo "  -s, --no-shutdown   Skip shutting down the system"
            echo "  -r, --dry-run       Perform a dry run without executing commands"
            echo "  -d, --debug         Enable debug mode, and dry run"
            echo "  -h, --help          Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo " try: shutdown.sh -h"
            exit 1
            ;;
    esac
done


perform_shutdown | tee $HOME/shutdown.log