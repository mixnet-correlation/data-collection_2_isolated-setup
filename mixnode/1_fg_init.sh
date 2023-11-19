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


printf "Initializing nym-mixnode ${MIXNODE_IDENTITY_KEY}...\n"

ip=$( hostname --ip-address )

printf "MIXNET_CONTRACT_ADDRESS='${MIXNET_CONTRACT_ADDRESS}'\n"

/root/nym-mixnode init --host "${ip}" --id "${MIXNODE_IDENTITY_KEY}" --wallet-address "${WALLET_ADDRESS}" --validators "${NYMD_VALIDATOR}"

sleep 2

# put the mixnode's bonding details into storage
/root/nym-mixnode node-details --id "${MIXNODE_IDENTITY_KEY}" 2>&1 | tee ~/nym-"${MIXNODE_IDENTITY_KEY}"-node-details.txt
cp nym-"${MIXNODE_IDENTITY_KEY}"-node-details.txt /root/data/

if [ ! -f "/root/.nym/mixnodes/${MIXNODE_IDENTITY_KEY}/config/config.toml" ]; then
    printf "Couldn't find config file --- exit\n"
    exit 1
fi

printf "Done!\n"
