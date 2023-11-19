#!/usr/bin/env bash

# Safety settings.
set -eu
shopt -s failglob


# Start the nym_mixnode process (fork to background in wrapper script).
printf "Starting nym-mixnode ${MIXNODE_IDENTITY_KEY}...\n"
/root/nym-mixnode run --id "${MIXNODE_IDENTITY_KEY}"
