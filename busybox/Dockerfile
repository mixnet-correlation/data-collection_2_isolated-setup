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

FROM ubuntu:20.04 as builder

ENV GOROOT=/usr/local/go
ENV GOPATH="${HOME}"/go
ENV GO111MODULE=on
ENV PATH="${PATH}":/usr/local/go/bin:"${HOME}"/go/bin
ENV BECH32_PREFIX=n
ENV WASMD_VERSION=v0.26.0

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get --yes install git curl build-essential \
    && curl https://dl.google.com/go/go1.17.5.linux-amd64.tar.gz | tar -C/usr/local -zxvf - \
    && git clone https://github.com/CosmWasm/wasmd.git \
    && cd wasmd \
    && git checkout "${WASMD_VERSION}" \
    && mkdir build \
    && go build -o ./build/nymd -mod=readonly -tags "netgo,ledger" -ldflags "-X github.com/cosmos/cosmos-sdk/version.Name=nymd -X github.com/cosmos/cosmos-sdk/version.AppName=nymd -X github.com/CosmWasm/wasmd/app.NodeDir=.nymd -X github.com/cosmos/cosmos-sdk/version.Version=${WASMD_VERSION} -X github.com/cosmos/cosmos-sdk/version.Commit=dc5ef6fe84f0a5e3b0894692a18cc48fb5b00adf -X github.com/CosmWasm/wasmd/app.Bech32Prefix=${BECH32_PREFIX} -X \"github.com/cosmos/cosmos-sdk/version.BuildTags=netgo,ledger\"" -trimpath ./cmd/wasmd


# Contract building stage

FROM bitnami/minideb:bullseye as contract_builder

ENV SSL_VERSION=1.0.2u
ENV OPENSSL_LIB_DIR=/usr/local/ssl/lib
ENV OPENSSL_INCLUDE_DIR=/usr/local/ssl/include
ENV OPENSSL_STATIC=1
ENV RUSTUP_HOME=/usr/local/rustup
ENV CARGO_HOME=/usr/local/cargo
ENV PATH=/usr/local/cargo/bin:"${PATH}"
# [MIXCORR] Fix Rust compiler version to avoid errors with NYMD contract uploading.
ENV RUSTC_VERSION="1.66.1"

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --yes \
        ca-certificates curl pkg-config libssl-dev git build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN curl https://www.openssl.org/source/openssl-"${SSL_VERSION}".tar.gz -O \
    && tar -xzf openssl-"${SSL_VERSION}".tar.gz \
    && cd openssl-"${SSL_VERSION}" \
    && ./config \
    && make depend \
    && make install \
    && cd .. \
    && rm -rf openssl-"${SSL_VERSION}"*

RUN curl https://sh.rustup.rs -sSf | sh -s -- --profile minimal --default-toolchain "${RUSTC_VERSION}" -y
RUN rustc --version

RUN git clone https://github.com/nymtech/nym.git /root/nym

WORKDIR /root/nym

# [MIXCORR] Check out specific version of Nym before building.
ARG mixcorr_nym_gittag
RUN git checkout tags/"${mixcorr_nym_gittag}"

# [MIXCORR] If patch files for this container exist, apply them before compiling.
COPY empty *.patch /root/nym/
RUN find /root/nym -name "*.patch" -exec patch -i {} -p1 \;

RUN rustup target add wasm32-unknown-unknown
RUN RUSTFLAGS='-C link-arg=-s' cargo build --manifest-path /root/nym/contracts/Cargo.toml --release --target wasm32-unknown-unknown


# Final stage build

FROM bitnami/minideb:bullseye

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --yes \
        ca-certificates curl pkg-config libssl-dev vim sudo libssl1.1 jq vim git build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /wasmd/build/nymd /root/nymd
COPY --from=builder /go/pkg/mod/github.com/!cosm!wasm/wasmvm@v1.0.0-beta10/api/libwasmvm.so /usr/lib/
COPY --from=contract_builder /root/nym/contracts/target/wasm32-unknown-unknown/release/mixnet_contract.wasm /root/mixnet_contract.wasm
COPY --from=contract_builder /root/nym/contracts/target/wasm32-unknown-unknown/release/vesting_contract.wasm /root/vesting_contract.wasm

WORKDIR /root

COPY ./scripts/ /root/scripts/
COPY ./validator-client-scripts /root/validator-client-scripts
COPY ./envs/local.env /root/local.env

RUN chown -R root:root /root \
    && chmod 0700 /root/nymd \
    && chmod 0700 /root/scripts/* \
    && chmod 0700 /root/validator-client-scripts \
    && chmod 0700 /root/mixnet_contract.wasm \
    && chmod 0700 /root/vesting_contract.wasm
