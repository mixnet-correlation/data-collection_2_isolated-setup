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

GATEWAY_DETAILS=vesting-nym-gateway-node-details.txt
HOST="$( cat data/${GATEWAY_DETAILS} | grep Host | awk '{print $2}' )"
OWNER_SIGNATURE="$( cat data/${GATEWAY_DETAILS} | grep Owner | awk '{print $3}' )"
SPHINX_KEY="$( cat data/${GATEWAY_DETAILS} | grep Sphinx | awk '{print $3}' )"
IDENTITY_KEY="$( cat data/${GATEWAY_DETAILS} | grep Identity | awk '{print $3}' )"


./validator-client-scripts --config-env-file "${CONFIG_ENV_FILE}" --mixnet-contract "${MIXNET_CONTRACT_ADDRESS}" --vesting-contract "${VESTING_CONTRACT_ADDRESS}" --mnemonic "${VESTING_GATEWAY_ADDRESS_MNEMONIC}" --nymd-url "${NYMD_VALIDATOR}" vesting-bond-gateway --amount 100000000 --host "${HOST}" --identity-key "${IDENTITY_KEY}" --mix-port 1789 --sphinx-key "${SPHINX_KEY}" --clients-port 9000 --version "${VERSION}" --signature "${OWNER_SIGNATURE}"
