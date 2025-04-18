#!/bin/bash

# Debug function to display variables
debug() {
  echo "Debugging information:"
  echo "Source directory: $source_dir"
  echo "Destination directory: $destination_dir"
  echo "Keep backups: $keep"
  echo "Format: $fmt"
  echo "Dry run: $dry_run"
}

# Help function to display usage
show_help() {
  echo "Usage: $0 [-h|--help] [-b|--debug] -s|--source <source_dir> -d|--dest <destination_dir> [-k|--keep <keep>] [-f|--fmt <fmt>]"
  echo ""
  echo "Options:"
  echo "  -h, --help           Show this help message and exit."
  echo "  -b, --debug          Enable debug mode."
  echo "  -s, --source         Specify the source directory (required)."
  echo "  -d, --dest           Specify the destination directory (required)."
  echo "  -k, --keep           Number of backups to keep (default: 7)."
  echo "  -f, --fmt            Backup in day-based (YYYYMMDD) or second-based (YYYYMMDDhhmmss) names: 'day' or 'sec' (default: 'day')."
  echo "  -r, --dry-run        Do not perform the actual backup, only show what would be done."
  echo ""
  echo "Examples:"
  echo "  $0 -s /path/to/source -d /path/to/destination"
  echo "  $0 --debug --source /path/to/source --dest /path/to/destination --keep 5 --fmt day"
  exit 0
}

# Perform the backup
perform_backup() {
  echo "Creating backup from $source_dir to $backup_file..."
  if [ -e "$backup_file" ]; then
    if ! $dry_run; then
      echo "Removing existing backup"
      rm "$backup_file"
      if [ $? -ne 0 ]; then
        echo "Error: Failed to remove existing backup."
        exit 1
      fi
    else
      echo "Dry run: Existing backup would be removed."
    fi
  else
    echo "No existing backup found, proceeding with backup."
  fi

  if ! $dry_run; then
    tar -czf "$backup_file" -C "$source_dir" . 2>&1 | while IFS= read -r line; do
      echo "  $line"
    done
    if [ $? -ne 0 ]; then
      echo "Error: Backup failed."
      exit 1
    fi
    echo "Backup created successfully: $backup_file"
  else
    echo "Dry run: Backup would be created with the following command:"
    echo "  tar -czf $backup_file -C $source_dir ."
  fi
  
  # Manage old backups
  echo "Keeping the last $keep backups..."
  if ! $dry_run; then
    (
      cd "$destination_dir"
      find . -maxdepth 1 -type f -name "backup-*" | sort -r | tail -n +$(($keep + 1)) | xargs rm -f
    )
    if [ $? -ne 0 ]; then
      echo "Error: Failed to remove old backups."
      exit 1
    fi
    echo "Old backups removed successfully."
  else
    echo "Dry run: Old backups would be removed with the following command:"
    echo "  find $destination_dir -maxdepth 1 -type f -name 'backup-*' | sort -r | tail -n +$(($keep + 1)) | xargs rm -f"
  fi
  
  # Show remaining backups 
  num_files=$(find "$destination_dir" -maxdepth 1 -type f -name "backup-*" 2>/dev/null | wc -l)

  # Get the min and max dates of the remaining files
  if [[ $num_files -gt 0 ]]; then
    min_date=$(find "$destination_dir" -maxdepth 1 -type f -name "backup-*" | sort | head -n 1 | sed -E 's/.*backup-([0-9]+)\..*/\1/')
    max_date=$(find "$destination_dir" -maxdepth 1 -type f -name "backup-*" | sort | tail -n 1 | sed -E 's/.*backup-([0-9]+)\..*/\1/')
    echo "Number of stored backups: $num_files"
    echo "Oldest backup date: $min_date"
    echo "Newest backup date: $max_date"
  else
    echo "No backups found in $destination_dir."
  fi

  # Show total disk usage of the backup directory
  total_size=$(du -sh "$destination_dir" 2>/dev/null | awk '{print $1}')
  echo "Total disk usage of backup directory: $total_size"

}

############################################## MAIN ##############################################

# Defaults
help=false
debug=false
keep=7
fmt=day
dry_run=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      help=true
      shift
      ;;
    -b|--debug)
      debug=true
      shift
      ;;
    -s|--source)
      source_dir="$2"
      shift 2
      ;;
    -d|--dest)
      destination_dir="$2"
      shift 2
      ;;
    -k|--keep)
      keep="$2"
      shift 2
      ;;
    -f|--fmt)
      fmt="$2"
      shift 2
      ;;
    -r|--dry-run)
      dry_run=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Debug mode
if $debug; then
  echo "Debug mode enabled. Commands will be printed."
  debug
  set -x
fi
if $dry_run; then
  echo "Dry run mode enabled. No changes will be made."
fi

# Show help if requested
if $help; then
  show_help
fi

# Ensure required arguments are provided
if [ -z "$source_dir" ] || [ -z "$destination_dir" ]; then
  echo "Error: Source and destination directories must be specified."
  show_help
fi

# Validate source directory
if [ ! -d "$source_dir" ] && [ ! -L "$source_dir" ]; then
  echo "Source directory does not exist or is not a valid symbolic link ($source_dir)"
  exit 1
fi

# Validate destination directory
if [ ! -d "$destination_dir" ] && [ ! -L "$destination_dir" ]; then
  echo "Destination directory does not exist or is not a valid symbolic link ($destination_dir)"
  exit 1
fi

# Validate format
if [[ "$fmt" != "day" && "$fmt" != "sec" ]]; then
  echo "Invalid format - 'day' or 'sec' are allowed"
  exit 1
fi

# Create the backup filename
case $fmt in
  sec)
    timestamp=$(date +"%Y%m%d%H%M%S")
    ;;
  day)
    timestamp=$(date +"%Y%m%d")
    ;;
esac
backup_file="$destination_dir/backup-$timestamp.tgz"

# Perform the backup
perform_backup

# Disable debug mode
if $debug; then
  set +x
  debug=false
  echo "Debug mode disabled."
fi
