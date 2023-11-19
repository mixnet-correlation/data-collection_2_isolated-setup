#!/usr/bin/env bash

# Copyright 2022-2023 Nym Technologies SA <contact@nymtech.net>
# Modifications copyright 2022-2023 Authors of paper "MixMatch: Flow Matching for Mixnet Traffic"
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Safety settings.
set -eu
shopt -s failglob


printf "Initializing nym-gateway...\n"

ip=$( hostname --ip-address )

printf "mixcorr_gateway_sphinxflow_dir='${mixcorr_gateway_sphinxflow_dir}'\n"
printf "MIXNET_CONTRACT_ADDRESS='${MIXNET_CONTRACT_ADDRESS}'\n"

# import gateway mnemonic from secrets
# the config env variables should set the validator-urls
/root/nym-gateway init --host "${ip}" --id "${ID}" --wallet-address "${WALLET_ADDRESS}" --mnemonic """${GATEWAY_MNEMONIC}"""

sleep 2

# put the gateway's bonding details into storage
/root/nym-gateway node-details --id "${ID}" 2>&1 | tee ~/"${ID}"-node-details.txt
cp "${ID}"-node-details.txt /root/data/"${ID}"-node-details.txt

if [ ! -f "/root/.nym/gateways/${ID}/config/config.toml" ]; then
    printf "Config files not found exiting...\n"
    exit 1
fi

printf "Done!\n"
