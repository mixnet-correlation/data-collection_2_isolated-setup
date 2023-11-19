#!/usr/bin/env bash

# Safety settings.
set -eu
shopt -s failglob


printf "Starting nym-client ${mixcorr_exp_run} and its requester and webserver...\n"

# Start the nym-client process.
/root/nym-client run --id "client_${mixcorr_exp_run}" &

sleep 2

# Start the nym-network-requester process.
/root/nym-network-requester &

sleep 2

# Start the python3-based webserver process (fork to background in wrapper script).
python3 -m http.server --bind 127.0.0.1 --directory "/root/data/${mixcorr_exp_id}_curl_run_${mixcorr_exp_run}/webserver_directory" 9909
