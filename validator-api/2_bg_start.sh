#!/usr/bin/env bash

# Safety settings.
set -eu
shopt -s failglob


# Start the nym_validator_api process (fork to background in wrapper script).
printf "Starting nym-validator-api...\n"
/root/nym-validator-api --id "${VALIDATOR_API_ID}"
