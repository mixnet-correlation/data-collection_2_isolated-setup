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


# Send funds to all relevant Nym addresses.

printf "Sending funds to all relevant Nym addresses...\n"

FUND_ADDRESSES=( "${MIXNODE_1_ADDRESS}" "${MIXNODE_2_ADDRESS}" "${MIXNODE_3_ADDRESS}" "${GATEWAY_ADDRESS}" "${REWARDING_VALIDATOR_ADDRESS}" "${CONTRACT_UPLOADER_ADDRESS}" "${MIXNET_CONTRACT_ACCOUNT_ADDRESS}" "${VESTING_CONTRACT_ACCOUNT_ADDRESS}" )

passphrase="passphrase"

for i in "${FUND_ADDRESSES[@]}";
do
    yes "${passphrase}" | /root/nymd tx bank send node_admin "${i}" --chain-id nymnet 2500000000u"${MIX_DENOM_DISPLAY}" --gas auto --gas-adjustment 1.3 --gas-prices 0.025u"${MIX_DENOM_DISPLAY}" -y

    printf "......... SENT FUNDS TO ${i} .........\n"

    # allow time for the tx to broadcast
    sleep 5
done

printf "Done!\n"
