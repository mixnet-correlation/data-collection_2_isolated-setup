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

CONFIG_ENV_FILE=/root/local.env

#create vesting schedules

VESTING_ADDRESS=( "${VESTING_GATEWAY_ADDRESS}" "${VESTING_MIXNODE_1_ADDRESS}" )

for i in "${VESTING_ADDRESS[@]}"; do

    # allow txs to broadcast before starting the next loop
    sleep 5

    # a random amount to create for the user
    AMOUNT=1000000000

    # --number-of-periods <NUMBER_OF_PERIODS>  - defaults to 8
    # --periods-seconds <PERIODS_SECONDS>  - defaults to the equivalent of 3 months if nothing set
    # --staking-address <STAKING_ADDRESS>  - not required atm
    # --start-time <START_TIME> - if nothing set equivalent of datetime.now - uses a unix timestamp if you want to set back in time
    # for example: 1652012979 - would resolve to the vesting schedule to start at - Sun May 08 2022 12:29:39 GMT+0000
    # lets make the vesting period intervals shorter
    ./validator-client-scripts --config-env-file "${CONFIG_ENV_FILE}" --mnemonic "${VESTING_CONTRACT_ADDRESS_MNEMONIC}" --nymd-url "${NYMD_VALIDATOR}" vesting-create-schedule --address "${i}" --amount "${AMOUNT}" --periods-seconds 1500 --number-of-periods 8

done
