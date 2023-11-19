#!/bin/bash

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

set -e

VERSION=1.0.1
CONFIG_ENV_FILE=/root/local.env

# let's attempt to loop through all the mixnodes in storage
# and bond them all in one hit
# these are hardcoded for the minimum topology to start
# you are at your own peril to add more mixnodes to the network
# for v1 it is what it is :)

MIXNODE_DETAILS=( "nym-mixnode-binary-0-node-details.txt" "nym-mixnode-binary-1-node-details.txt" "nym-mixnode-binary-2-node-details.txt" )
MIXNODE_MNEMONICS=( "${MIXNODE_1_MNEMONIC}" "${MIXNODE_2_MNEMONIC}" "${MIXNODE_3_MNEMONIC}" )

counter=0
for i in "${MIXNODE_DETAILS[@]}"; do

    HOST="$( cat data/${i} | grep Host | awk '{print $2}' )"
    OWNER_SIGNATURE="$( cat data/${i} | grep Owner | awk '{print $3}' )"
    SPHINX_KEY="$( cat data/${i} | grep Sphinx | awk '{print $3}' )"
    IDENTITY_KEY="$( cat data/${i} | grep Identity | awk '{print $3}' )"

    # allow txs to broadcast before starting the next script
    sleep 5

    ./validator-client-scripts --config-env-file "${CONFIG_ENV_FILE}" --mixnet-contract "${MIXNET_CONTRACT_ADDRESS}" --vesting-contract "${VESTING_CONTRACT_ADDRESS}" --mnemonic "${MIXNODE_MNEMONICS[$counter]}" --nymd-url "${NYMD_VALIDATOR}" bond-mixnode --amount 1000000000 --host "${HOST}" --http-api-port 8000 --mix-port 1789 --identity-key "${IDENTITY_KEY}" --sphinx-key "${SPHINX_KEY}" --verloc-port 1790 --version "${VERSION}" --profit-margin-percent 10 --signature "${OWNER_SIGNATURE}"

    counter=$(( counter + 1 ))

done
