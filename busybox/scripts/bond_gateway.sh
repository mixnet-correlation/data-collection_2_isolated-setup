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

printf "${VESTING_CONTRACT_ADDRESS}\n"
printf "${MIXNET_CONTRACT_ADDRESS}\n"
printf "${NYMD_VALIDATOR}\n"

# $1 mnemonic
# $2 host
# $3 identity-key
# $4 sphinx-key
# $5 signature

./validator-client-scripts --config-env-file "${CONFIG_ENV_FILE}" --mixnet-contract "${MIXNET_CONTRACT_ADDRESS}" --vesting-contract "${VESTING_CONTRACT_ADDRESS}" --mnemonic "${1}" --nymd-url "${NYMD_VALIDATOR}" bond-gateway --amount 1000000000 --host "${2}" --identity-key "${3}" --mix-port 1789 --sphinx-key "${4}" --clients-port 9000 --version "${VERSION}" --signature "${5}"
