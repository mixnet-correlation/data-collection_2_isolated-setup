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

VESTING_MIXNODE=nym-vesting-mixnode-binary-node-details.txt
HOST="$( cat data/${VESTING_MIXNODE} | grep Host | awk '{print $2}' )"
OWNER_SIGNATURE="$( cat data/${VESTING_MIXNODE} | grep Owner | awk '{print $3}' )"
SPHINX_KEY="$( cat data/${VESTING_MIXNODE} | grep Sphinx | awk '{print $3}' )"
IDENTITY_KEY="$( cat data/${VESTING_MIXNODE} | grep Identity | awk '{print $3}' )"


./validator-client-scripts --config-env-file "${CONFIG_ENV_FILE}" --mixnet-contract "${MIXNET_CONTRACT_ADDRESS}" --vesting-contract "${VESTING_CONTRACT_ADDRESS}" --mnemonic "${VESTING_MIXNODE_1_MNEMONIC}" --nymd-url "${NYMD_VALIDATOR}" vesting-bond-mixnode --amount 100000000 --host "${HOST}" --http-api-port 8000 --mix-port 1789 --identity-key "${IDENTITY_KEY}" --sphinx-key "${SPHINX_KEY}" --verloc-port 1790 --version "${VERSION}" --profit-margin-percent 10 --signature "${OWNER_SIGNATURE}"
