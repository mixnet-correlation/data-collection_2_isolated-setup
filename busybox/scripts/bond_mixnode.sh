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

# $1 host
# $2 identity
# $3 sphinx
# $4 signature

./validator-client-scripts --config-env-file "${CONFIG_ENV_FILE}" --mixnet-contract "${MIXNET_CONTRACT_ADDRESS}" --vesting-contract "${VESTING_CONTRACT_ADDRESS}" --mnemonic "${3}" --nymd-url "${NYMD_VALIDATOR}" bond-mixnode --amount 1000000000 --host "${1}" --http-api-port 8000 --mix-port 1789 --identity-key "${2}" --sphinx-key "${3}" --verloc-port 1790 --version "${VERSION}" --profit-margin-percent 10 --signature "${4}"
