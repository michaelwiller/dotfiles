#!/usr/bin/env bash
# Description: This script destroys all TPA and Vagrant clusters based on a configuration file.

CONFIG_FILE=~/.config/clusters.conf

# Check if the configuration file exists, if not, create a template
create_config_template() {
    echo "Creating configuration file template at $CONFIG_FILE..."
    mkdir -p "$(dirname "$CONFIG_FILE")"  # Ensure the directory exists
    cat > "$CONFIG_FILE" <<EOF
# ~/.config/clusters.conf
# Configuration file for cluster management
# Define TPA and Vagrant clusters below.

[tpa]
# Example:
# ~/clusters/tpa/cluster1
# ~/clusters/tpa/cluster2

[vagrant]
# Example:
# ~/clusters/vagrant/cluster1
# ~/clusters/vagrant/cluster2
EOF
}

# List available sections in the config file
list_sections() {
  awk '/^\[.*\]$/ { gsub(/[\[\]]/, "", $0); print $0 }' "$CONFIG_FILE"
}

# Function to read clusters from the config file
# It reads the specified section (tpa or vagrant) and prints the cluster directories
read_clusters() {
  local section=$1
  awk -v section="[$section]" '
    $0 == section { in_section=1; next }
    /^\[/ { in_section=0 }
    in_section && $0 !~ /^#/ && $0 !~ /^\s*$/ { print $0 }
  ' "$CONFIG_FILE"
}


destroy-all-tpa() {
  destroy-tpa-cluster() {
    cluster_dir=$1
    echo "$cluster_dir:"
    if [ ! -f "$cluster_dir/config.yml" ]; then
      echo "  No config.yml file found in $cluster_dir"
      return
    fi
    cd "$cluster_dir"
    tpaexec status . | grep "is running" > /dev/null 2>&1
    is_running=$?
    cd ..
    if [ $is_running -eq 0 ]; then
      cd "$cluster_dir"
      tpaexec deprovision . | while IFS= read -r line; do
        echo "  $line"
      done
      cd ..
    else
      echo "  Cluster not running"
    fi
  }

  echo "TPA clusters:"
  for cluster_dir in $(read_clusters tpa); do
    destroy-tpa-cluster "$cluster_dir" | while IFS= read -r line; do
      echo "    $line"
    done
    echo ""
  done
}

destroy-all-vagrant() {
  destroy-vagrant-cluster() {
    cluster_dir=$1
    echo "$cluster_dir:"
    if [ ! -f "$cluster_dir/Vagrantfile" ]; then
      echo "  No Vagrantfile found in $cluster_dir"
      return
    fi
    cd "$cluster_dir"
    vagrant status | grep "is running" > /dev/null 2>&1
    is_running=$?
    cd ..
    if [ $is_running -eq 0 ]; then
      cd "$cluster_dir"
      vagrant halt -f 2>&1 | while IFS= read -r line; do
        echo "  $line"
      done
      cd ..
    else
      echo "  Cluster not running"
    fi
  }
  echo "VAGRANT clusters:"
  for cluster_dir in $(read_clusters vagrant); do
    destroy-vagrant-cluster "$cluster_dir" | while IFS= read -r line; do
      echo "    $line"
    done
    echo ""
  done
}

destroy_clusters() {
  for section in $(list_sections); do
    case $section in
      tpa)
        destroy-all-tpa
        ;;
      vagrant)
        destroy-all-vagrant
        ;;
      *)
        echo "Unknown section: $section"
        ;;
    esac
  done
}


if [ ! -f "$CONFIG_FILE" ]; then
  create_config_template
  echo "Template created. Please edit $CONFIG_FILE to add your clusters."
  exit 0
fi

destroy_clusters