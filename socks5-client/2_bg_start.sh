#!/usr/bin/env bash

# Safety settings.
set -eu
shopt -s failglob


# Start the nym-socks5-client process (fork to background in wrapper script).
printf "Starting nym-socks5-client ${mixcorr_exp_run}...\n"
/root/nym-socks5-client run --id "socks5-client_${mixcorr_exp_run}"
