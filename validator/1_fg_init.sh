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


ldlibpath_status="${LD_LIBRARY_PATH:=not_set}"
if [[ "${ldlibpath_status}" == "not_set" ]];
then
    export LD_LIBRARY_PATH=/root
else
    export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}":/root
fi

passphrase="passphrase"

if [[ "${1}" == "genesis" ]];
then

    if [ ! -f "/root/.nymd/config/genesis.json" ];
    then

        printf "Initializing genesis nym-validator...\n"

        /root/nymd init nymnet --chain-id nymnet

        # staking/governance token is hardcoded in config, change this
        sed -i "s/\"stake\"/\"u${STAKE_DENOM_DISPLAY}\"/" /root/.nymd/config/genesis.json
        sed -i 's/minimum-gas-prices = ""/minimum-gas-prices = "0.025u'"${MIX_DENOM_DISPLAY}"'"/' /root/.nymd/config/app.toml
        sed -i '0,/enable = false/s//enable = true/g' /root/.nymd/config/app.toml
        sed -i 's/cors_allowed_origins = \[\]/cors_allowed_origins = \["*"\]/' /root/.nymd/config/config.toml
        sed -i 's/create_empty_blocks = true/create_empty_blocks = false/' /root/.nymd/config/config.toml
        sed -i 's/laddr = "tcp:\/\/127.0.0.1:26657"/laddr = "tcp:\/\/0.0.0.0:26657"/' /root/.nymd/config/config.toml

        # create accounts - import from secrets
        yes "${passphrase}" | /root/nymd keys add node_admin 2>&1 > /dev/null | tail -n 1 > /root/.nymd/node_admin_mnemonic
        yes "${passphrase}" | /root/nymd keys add secondary 2>&1 > /dev/null | tail -n 1 > /root/.nymd/secondary
        yes "${MIXNET_CONTRACT_ADDRESS_MNEMONIC}" | /root/nymd keys add mixnet_contract_owner --recover --keyring-backend test
        yes "${VESTING_CONTRACT_ADDRESS_MNEMONIC}" | /root/nymd keys add vesting_contract_owner --recover --keyring-backend test
        yes "${CONTRACT_UPLOADER_ADDRESS_MNEMONIC}" | /root/nymd keys add contract_uploader --recover --keyring-backend test

        # copy values to storage
        cp /root/.nymd/node_admin_mnemonic /root/data
        cp /root/.nymd/secondary /root/data

        # add genesis accounts with some initial tokens
        GENESIS_ADDRESS=$( yes "${passphrase}" | /root/nymd keys show node_admin -a )
        SECONDARY_ADDRESS=$( yes "${passphrase}" | /root/nymd keys show secondary -a )
        yes "${passphrase}" | /root/nymd add-genesis-account "${GENESIS_ADDRESS}" 1000000000000000u"${MIX_DENOM_DISPLAY}",1000000000000000u"${STAKE_DENOM_DISPLAY}"
        yes "${passphrase}" | /root/nymd add-genesis-account "${SECONDARY_ADDRESS}" 1000000000000000u"${MIX_DENOM_DISPLAY}",1000000000000000u"${STAKE_DENOM_DISPLAY}"

        yes "${passphrase}" | /root/nymd gentx node_admin 1000000000u"${STAKE_DENOM_DISPLAY}" --chain-id nymnet
        /root/nymd collect-gentxs
        /root/nymd validate-genesis

        printf "Done!\n"

    else
        printf "Validator already initialized, starting with the existing configuration.\n"
        printf "If you want to re-init the validator, destroy the existing container.\n"
    fi

fi
