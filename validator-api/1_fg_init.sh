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


# Save configuration file for nym-validator-api based on environment variables.

printf "Saving configuration of nym-validator-api...\n"

/root/nym-validator-api --id "${VALIDATOR_API_ID}" --mnemonic """${REWARDING_VALIDATOR_MNEMONIC}""" --nymd-validator "${NYMD_VALIDATOR}" --enable-monitor --enable-rewarding --save-config

printf "Done!\n"
