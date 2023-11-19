#!/usr/bin/env bash

# Safety settings.
set -eu
shopt -s failglob


printf "Initializing nym-client ${mixcorr_exp_run} and its requester and webserver...\n"

# Initialize nym-client, write identity data to shared storage.
gateway_identity_key=$( cat /root/data/nym-gateway-node-details.txt | grep Identity | awk '{print $3}' )

client_init=$( /root/nym-client init --id "client_${mixcorr_exp_run}" --gateway "${gateway_identity_key}" )
printf "${client_init}\n"

client_addr=$( echo "${client_init}" | grep "The address of this client is: " | grep -o -E "[[:alnum:]]+\.[[:alnum:]]+\@[[:alnum:]]+" )
client_identity_key=$( echo "${client_addr}" | grep -o -E "^[[:alnum:]]+" )
printf "Following nym-client address was generated and matched for client_${mixcorr_exp_run}:\n${client_addr}\n"
printf "Of this address, the identity part for our tracking purposes for client_${mixcorr_exp_run} is:\n${client_identity_key}\n"


if [[ "${mixcorr_exp_id}" == "exp05" ]]; then

    printf "\nVariable values 'average_packet_delay' and 'average_ack_delay' of this nym-client before their changes from '50ms' to '20ms':\n"
    grep "average_packet_delay" "/root/.nym/clients/client_${mixcorr_exp_run}/config/config.toml"
    grep "average_ack_delay" "/root/.nym/clients/client_${mixcorr_exp_run}/config/config.toml"
    printf "\n"

    # exp05: Modify 'config.toml' of this nym-client for lower average per-mix packet delays.
    sed -i "s/average_packet_delay = '50ms'/average_packet_delay = '20ms'/g" "/root/.nym/clients/client_${mixcorr_exp_run}/config/config.toml"
    sed -i "s/average_ack_delay = '50ms'/average_ack_delay = '20ms'/g" "/root/.nym/clients/client_${mixcorr_exp_run}/config/config.toml"

    printf "Variable values 'average_packet_delay' and 'average_ack_delay' of this nym-client after their changes from '50ms' to '20ms':\n"
    grep "average_packet_delay" "/root/.nym/clients/client_${mixcorr_exp_run}/config/config.toml"
    grep "average_ack_delay" "/root/.nym/clients/client_${mixcorr_exp_run}/config/config.toml"
    printf "\n"

elif [[ "${mixcorr_exp_id}" == "exp06" ]]; then

    printf "\nVariable values 'average_packet_delay' and 'average_ack_delay' of this nym-client before their changes from '50ms' to '200ms':\n"
    grep "average_packet_delay" "/root/.nym/clients/client_${mixcorr_exp_run}/config/config.toml"
    grep "average_ack_delay" "/root/.nym/clients/client_${mixcorr_exp_run}/config/config.toml"
    printf "\n"

    # exp06: Modify 'config.toml' of this nym-socks5-client for higher average per-mix packet delays.
    sed -i "s/average_packet_delay = '50ms'/average_packet_delay = '200ms'/g" "/root/.nym/clients/client_${mixcorr_exp_run}/config/config.toml"
    sed -i "s/average_ack_delay = '50ms'/average_ack_delay = '200ms'/g" "/root/.nym/clients/client_${mixcorr_exp_run}/config/config.toml"

    printf "Variable values 'average_packet_delay' and 'average_ack_delay' of this nym-client after their changes from '50ms' to '200ms':\n"
    grep "average_packet_delay" "/root/.nym/clients/client_${mixcorr_exp_run}/config/config.toml"
    grep "average_ack_delay" "/root/.nym/clients/client_${mixcorr_exp_run}/config/config.toml"
    printf "\n"

fi


mkdir -p "/root/data/${mixcorr_exp_id}_curl_run_${mixcorr_exp_run}/client_nym_folder"
printf "${client_addr}\n" > "/root/data/${mixcorr_exp_id}_curl_run_${mixcorr_exp_run}/address_responder_nym-client.txt"


# Prepare folder and allowed IPs for nym-network-requester.
mkdir -p /root/.nym/service-providers/network-requester
printf "127.0.0.1\n" > /root/.nym/service-providers/network-requester/allowed.list


# Prepare folder and HTTP document for Python3 webserver.
mkdir -p "/root/data/${mixcorr_exp_id}_curl_run_${mixcorr_exp_run}/webserver_directory"
cp "/root/data/document_to_download.txt" "/root/data/${mixcorr_exp_id}_curl_run_${mixcorr_exp_run}/webserver_directory/document.txt"
printf "_run-${mixcorr_exp_run}" >> "/root/data/${mixcorr_exp_id}_curl_run_${mixcorr_exp_run}/webserver_directory/document.txt"


printf "Done!\n"
