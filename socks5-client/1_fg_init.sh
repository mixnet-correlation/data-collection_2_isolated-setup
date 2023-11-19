#!/usr/bin/env bash

# Safety settings.
set -eu
shopt -s failglob


printf "Initializing nym-socks5-client ${mixcorr_exp_run}...\n"

# Initialize nym-socks5-client, write identity data to shared storage.
gateway_identity_key=$( cat /root/data/nym-gateway-node-details.txt | grep Identity | awk '{print $3}' )
provider_identity_key=$( cat "/root/data/${mixcorr_exp_id}_curl_run_${mixcorr_exp_run}/address_responder_nym-client.txt" )

socks5client_init=$( /root/nym-socks5-client init --id "socks5-client_${mixcorr_exp_run}" --gateway "${gateway_identity_key}" --provider "${provider_identity_key}" )
printf "${socks5client_init}\n"

socks5client_addr=$( echo "${socks5client_init}" | grep "The address of this client is: " | grep -o -E "[[:alnum:]]+\.[[:alnum:]]+\@[[:alnum:]]+" )
socks5client_identity_key=$( echo "${socks5client_addr}" | grep -o -E "^[[:alnum:]]+" )
printf "Following nym-socks5-client address was generated and matched for socks5-client_${mixcorr_exp_run}:\n${socks5client_addr}\n"
printf "Of this address, the identity part for our tracking purposes for socks5-client_${mixcorr_exp_run} is:\n${socks5client_identity_key}\n"


if [[ "${mixcorr_exp_id}" == "exp05" ]]; then

    printf "\nVariable values 'average_packet_delay' and 'average_ack_delay' of this nym-socks5-client before their changes from '50ms' to '20ms':\n"
    grep "average_packet_delay" "/root/.nym/socks5-clients/socks5-client_${mixcorr_exp_run}/config/config.toml"
    grep "average_ack_delay" "/root/.nym/socks5-clients/socks5-client_${mixcorr_exp_run}/config/config.toml"
    printf "\n"

    # exp05: Modify 'config.toml' of this nym-socks5-client for lower average per-mix packet delays.
    sed -i "s/average_packet_delay = '50ms'/average_packet_delay = '20ms'/g" "/root/.nym/socks5-clients/socks5-client_${mixcorr_exp_run}/config/config.toml"
    sed -i "s/average_ack_delay = '50ms'/average_ack_delay = '20ms'/g" "/root/.nym/socks5-clients/socks5-client_${mixcorr_exp_run}/config/config.toml"

    printf "Variable values 'average_packet_delay' and 'average_ack_delay' of this nym-socks5-client after their changes from '50ms' to '20ms':\n"
    grep "average_packet_delay" "/root/.nym/socks5-clients/socks5-client_${mixcorr_exp_run}/config/config.toml"
    grep "average_ack_delay" "/root/.nym/socks5-clients/socks5-client_${mixcorr_exp_run}/config/config.toml"
    printf "\n"

elif [[ "${mixcorr_exp_id}" == "exp06" ]]; then

    printf "\nVariable values 'average_packet_delay' and 'average_ack_delay' of this nym-socks5-client before their changes from '50ms' to '200ms':\n"
    grep "average_packet_delay" "/root/.nym/socks5-clients/socks5-client_${mixcorr_exp_run}/config/config.toml"
    grep "average_ack_delay" "/root/.nym/socks5-clients/socks5-client_${mixcorr_exp_run}/config/config.toml"
    printf "\n"

    # exp06: Modify 'config.toml' of this nym-socks5-client for higher average per-mix packet delays.
    sed -i "s/average_packet_delay = '50ms'/average_packet_delay = '200ms'/g" "/root/.nym/socks5-clients/socks5-client_${mixcorr_exp_run}/config/config.toml"
    sed -i "s/average_ack_delay = '50ms'/average_ack_delay = '200ms'/g" "/root/.nym/socks5-clients/socks5-client_${mixcorr_exp_run}/config/config.toml"

    printf "Variable values 'average_packet_delay' and 'average_ack_delay' of this nym-socks5-client after their changes from '50ms' to '200ms':\n"
    grep "average_packet_delay" "/root/.nym/socks5-clients/socks5-client_${mixcorr_exp_run}/config/config.toml"
    grep "average_ack_delay" "/root/.nym/socks5-clients/socks5-client_${mixcorr_exp_run}/config/config.toml"
    printf "\n"

fi


printf "${socks5client_addr}\n" > "/root/data/${mixcorr_exp_id}_curl_run_${mixcorr_exp_run}/address_initiator_nym-socks5-client.txt"

mkdir -p "/root/data/${mixcorr_exp_id}_curl_run_${mixcorr_exp_run}/socks5client_nym_folder"
mkdir -p "/root/data/${mixcorr_exp_id}_curl_run_${mixcorr_exp_run}/curl_client_directory"

printf "Done!\n"
