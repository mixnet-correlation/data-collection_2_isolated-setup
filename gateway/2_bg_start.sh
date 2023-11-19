#!/usr/bin/env bash

# Safety settings.
set -eu
shopt -s failglob


# Start the nym_gateway process (fork to background in wrapper script).
printf "Starting nym-gateway...\n"
/root/nym-gateway run --id "${ID}"
