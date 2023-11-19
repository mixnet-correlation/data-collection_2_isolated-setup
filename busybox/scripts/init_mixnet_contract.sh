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

FILE_NAME=/root/data/mixnet_contract.json

add_mixnet_address_to_keyring() {
    yes "${MIXNET_CONTRACT_ADDRESS_MNEMONIC}" | ./"${BINARY_NAME}" keys add mixnet_contract_owner --recover --keyring-backend test
    ./"""${BINARY_NAME}""" keys show "${CONTRACT_OWNER}" --keyring-backend test -a
}

init_mixnet_contract() {
    # eventually let's move to use the validator-client-scripts-binary

    MIXNET_ADDRESS=$( ./"""${BINARY_NAME}""" keys show "${CONTRACT_OWNER}" --keyring-backend test -a )

    sleep 3

    yes | ./"${BINARY_NAME}" tx wasm instantiate "${CODE_ID}" "{\"rewarding_validator_address\": \"${REWARDING_VALIDATOR_ADDRESS}\", \"mixnet_denom\" : \"u${MIX_DENOM_DISPLAY}\"}" --from "${CONTRACT_OWNER}" --admin "${MIXNET_ADDRESS}" --label 'mixnet-init-contract' --chain-id "${CHAIN_NAME}" --gas-prices 0.025u"${MIX_DENOM_DISPLAY}" --node "${NYMD_VALIDATOR}" --keyring-backend test --gas auto --gas-adjustment 1.3 -b block --output json > /root/data/mixnet_contract.json

    sleep 5

    # todo get the mixnet contract from the logs
    cat "${FILE_NAME}" | jq .logs[].events | jq .[].attributes | jq .[] | jq .value | head -n 1 | tr -d '"' > mixnet_address.txt

    sleep 5

    #copy to file storage
    cp mixnet_address.txt /root/data
}

# add the mixnet keys to the nym executable
add_mixnet_address_to_keyring

#init the mixnet contract
init_mixnet_contract
