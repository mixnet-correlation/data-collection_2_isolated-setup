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

# these will be injected via env variables - temp put in to script out the process
# lets move this process shortly into using the validator-client-script binary

add_contract_uploader_to_keyring() {
    yes "${CONTRACT_UPLOADER_ADDRESS_MNEMONIC}" | ./"${BINARY_NAME}" keys add contract_uploader --recover --keyring-backend test
    ./"""${BINARY_NAME}""" keys show "${CONTRACT_UPLOADER}" --keyring-backend test -a
}

upload_contracts() {

    CONTRACTS=( "mixnet_contract.wasm" "vesting_contract.wasm" )

    for i in "${CONTRACTS[@]}"; do

        # upload contracts
        yes | ./"${BINARY_NAME}" tx wasm store "${i}" --from "${CONTRACT_UPLOADER}" --chain-id "${CHAIN_NAME}" --gas-prices 0.025u"${MIX_DENOM_DISPLAY}" --gas auto --gas-adjustment 1.3 --node "${NYMD_VALIDATOR}" --keyring-backend test -b block --output json

        # allow txs to broadcast
        sleep 10

    done
}

# add the mixnet keys to the nym executable
add_contract_uploader_to_keyring

#upload the contracts
upload_contracts
