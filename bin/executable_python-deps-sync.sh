#!/usr/bin/env bash

# python-deps-sync.sh
# Sync the "homebin" Python tools environment from a requirements file.
#
# Usage:
#   ./python-deps-sync.sh
#   ./python-deps-sync.sh --venv /path/to/venv --requirements ~/bin/homebin-requirements.txt
#
# This is intended for a single shared tools venv (e.g. ~/.venv/homebin) that backs
# CLI scripts in ~/bin.

set -euo pipefail

VENV=${HOMEBIN_VENV:-$HOME/.venv/homebin}
REQ_FILE=${HOMEBIN_REQUIREMENTS:-$HOME/bin/homebin-requirements.txt}

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  --venv PATH            Virtualenv to use/create (default: $VENV)
  --requirements PATH    Requirements file (default: $REQ_FILE)
  --help                Show this message

Example:
  $(basename "$0")

EOF
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --venv)
      VENV="$2"; shift 2;;
    --requirements)
      REQ_FILE="$2"; shift 2;;
    --help)
      usage;;
    *)
      echo "Unknown option: $1" >&2
      usage
      ;;
  esac
done

if [[ ! -f "$REQ_FILE" ]]; then
  echo "ERROR: requirements file not found: $REQ_FILE" >&2
  echo "Create it and list the needed packages (e.g. pyyaml)" >&2
  exit 1
fi

if [[ ! -d "$VENV" ]]; then
  echo "Creating Python virtualenv: $VENV"
  python3 -m venv "$VENV"
fi

# Activate the tools venv for the remainder of this script.
# shellcheck source=/dev/null
source "$VENV/bin/activate"

echo "Upgrading pip/setuptools/wheel in $VENV..."
python -m pip install --upgrade pip setuptools wheel

echo "Installing requirements from $REQ_FILE..."
python -m pip install -r "$REQ_FILE"

echo "Done. To use this environment, activate it with:"
echo "  source $VENV/bin/activate"
