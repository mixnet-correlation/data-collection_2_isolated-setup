#!/usr/bin/env bash

# Safety settings.
set -eu
shopt -s failglob


# Start the nym_validator process (fork to background in wrapper script).
printf "Starting nym-validator...\n"
/root/nymd start
