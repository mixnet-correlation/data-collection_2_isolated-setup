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

FILE_NAME=/root/data/vesting_contract.json

# these will be injected via env variables
add_vesting_address_to_keyring() {
    yes "${VESTING_CONTRACT_ADDRESS_MNEMONIC}" | ./"${BINARY_NAME}" keys add vesting_contract_owner --recover --keyring-backend test
    ./"""${BINARY_NAME}""" keys show "${CONTRACT_OWNER}" --keyring-backend test -a
}

init_vesting_contract() {
    # eventually let's move to use the validator-client-scripts-binary
    #retrieve mixnet contract address from PV storage

    VESTING_ADDRESS=$( ./"""${BINARY_NAME}""" keys show "${CONTRACT_OWNER}" --keyring-backend test -a )

    sleep 3

    yes | ./"${BINARY_NAME}" tx wasm instantiate "${CODE_ID}" "{\"mixnet_contract_address\" : \"${MIXNET_CONTRACT_ADDRESS}\", \"mix_denom\" : \"u${MIX_DENOM_DISPLAY}\"}" --from "${CONTRACT_OWNER}" --admin "${VESTING_ADDRESS}" --label 'vesting-init-contract' --chain-id "${CHAIN_NAME}" --gas-prices 0.025u"${MIX_DENOM_DISPLAY}" --node "${NYMD_VALIDATOR}" --keyring-backend test --gas auto --gas-adjustment 1.5 -b block --output json > "${FILE_NAME}"

    sleep 10

    cat "${FILE_NAME}"

    # todo get the mixnet contract from the logs
    cat "${FILE_NAME}" | jq .logs[].events | jq .[].attributes | jq .[] | jq .value | head -n 1 | tr -d '"' > vesting_address.txt

    # move vesting address to mount
    cp /root/vesting_address.txt /root/data/

    sleep 5
}

# add the mixnet keys to the nym executable
add_vesting_address_to_keyring

#init the vesting contract
init_vesting_contract
