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

FROM golang:buster as builder

ENV GOROOT=/usr/local/go
ENV GOPATH="${HOME}"/go
ENV GO111MODULE=on
ENV PATH="${PATH}":/usr/local/go/bin:"${HOME}"/go/bin
ENV BECH32_PREFIX=n
ENV WASMD_VERSION=v0.27.0
ENV NYM_APP_NAME=nymd

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --yes git build-essential file

RUN git clone https://github.com/CosmWasm/wasmd.git \
    && cd wasmd \
    && git checkout "${WASMD_VERSION}" \
    && mkdir build

RUN cd wasmd \
    && go build -o ./build/nymd -mod=readonly -tags "netgo,ledger" -ldflags "-X github.com/cosmos/cosmos-sdk/version.Name=nymd -X github.com/cosmos/cosmos-sdk/version.AppName=nymd -X github.com/CosmWasm/wasmd/app.NodeDir=.nymd -X github.com/cosmos/cosmos-sdk/version.Version=${WASMD_VERSION} -X github.com/cosmos/cosmos-sdk/version.Commit=dc5ef6fe84f0a5e3b0894692a18cc48fb5b00adf -X github.com/CosmWasm/wasmd/app.Bech32Prefix=${BECH32_PREFIX} -X \"github.com/cosmos/cosmos-sdk/version.BuildTags=netgo,ledger\"" -trimpath ./cmd/wasmd

RUN find . -type f -name 'libwasm*.so' -exec cp {} / \;


# Final stage build

FROM bitnami/minideb:bullseye

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --yes \
        libssl1.1 ca-certificates jq curl vim procps iproute2 rsync \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /go/wasmd/build/nymd /root/nymd
COPY --from=builder /*.so /usr/lib/

WORKDIR /root

COPY 1_fg_init.sh .
COPY 2_bg_start.sh .
COPY 3_fg_send_funds.sh .

RUN chown -R root:root /root \
    && chmod 0700 /root/nymd \
    && chmod 0700 /root/1_fg_init.sh \
    && chmod 0700 /root/2_bg_start.sh \
    && chmod 0700 /root/3_fg_send_funds.sh
