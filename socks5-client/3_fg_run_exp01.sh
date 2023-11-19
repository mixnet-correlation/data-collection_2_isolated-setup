#!/usr/bin/env bash

# Safety settings.
set -eu
shopt -s failglob


printf "Conducting experiment ${mixcorr_exp_id}, run ${mixcorr_exp_run}...\n"

# Timestamp: Seconds since UNIX Epoch (Jan 01, 1970) with current nanoseconds appended.
ts_log="+%s%N"
start=$( date "${ts_log}" )

# Header 'Accept-Encoding: identity' ensures that no compression is applied.
curl --proxy socks5h://127.0.0.1:1080 --header "Accept-Encoding: identity" --output "/root/data/${mixcorr_exp_id}_curl_run_${mixcorr_exp_run}/curl_client_directory/document.txt" http://127.0.0.1:9909/document.txt

end=$( date "${ts_log}" )

cat << EOF > "/root/data/${mixcorr_exp_id}_curl_run_${mixcorr_exp_run}/experiment.json"
{
    "start": ${start},
    "end": ${end}
}
EOF

printf "Experiment ${mixcorr_exp_id}, run ${mixcorr_exp_run} concluded!\n"
