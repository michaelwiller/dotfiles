#!env bash

if which kubectl >/dev/null 2>&1; then

	source <(kubectl complete bash)

fi
