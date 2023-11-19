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

FROM bitnami/minideb:bullseye as builder

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

RUN cargo build --manifest-path /root/nym/mixnode/Cargo.toml --release


# Final stage build

FROM bitnami/minideb:bullseye

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --yes \
        ca-certificates pkg-config libssl-dev build-essential \
        procps iproute2 curl jq htop tree vim tmux git rsync \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /root/nym/target/release/nym-mixnode /root/nym-mixnode

WORKDIR /root

COPY ./1_fg_init.sh .
COPY ./2_bg_start.sh .

RUN chown -R root:root /root \
    && chmod 0700 /root/nym-mixnode \
    && chmod 0700 /root/1_fg_init.sh \
    && chmod 0700 /root/2_bg_start.sh
