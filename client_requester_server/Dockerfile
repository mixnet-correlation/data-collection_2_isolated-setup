FROM rust:1.63.0-bullseye as builder

RUN DEBIAN_FRONTEND=noninteractive apt-get update --yes \
    && DEBIAN_FRONTEND=noninteractive apt-get autoremove --purge \
    && DEBIAN_FRONTEND=noninteractive apt-get clean

RUN DEBIAN_FRONTEND=noninteractive apt-get install --yes \
        pkg-config build-essential ca-certificates gnupg libssl-dev \
        apt-transport-https software-properties-common lsb-release \
        curl jq htop tree tmux git python3-pip

RUN rustup show

# [MIXCORR] Check out specific version of Nym before building.
RUN git clone https://github.com/nymtech/nym.git /root/nym
WORKDIR /root/nym
ARG mixcorr_nym_gittag
RUN git reset --hard \
    && git pull \
    && git checkout tags/"${mixcorr_nym_gittag}"

# [MIXCORR] If patch files for this container exist, apply them before compiling.
COPY empty *.patch /root/nym/
RUN find /root/nym -name "*.patch" -exec patch -i {} -p1 \;

RUN cargo build --manifest-path /root/nym/clients/native/Cargo.toml --release
RUN cargo build --manifest-path /root/nym/service-providers/network-requester/Cargo.toml --release


# Final stage build

FROM bitnami/minideb:bullseye

RUN DEBIAN_FRONTEND=noninteractive apt-get update --yes \
    && DEBIAN_FRONTEND=noninteractive apt-get autoremove --purge \
    && DEBIAN_FRONTEND=noninteractive apt-get clean

RUN DEBIAN_FRONTEND=noninteractive apt-get install --yes \
    ca-certificates gnupg libssl-dev software-properties-common \
    lsb-release procps iproute2 curl jq htop tree vim tmux git rsync \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /root/nym/target/release/nym-client /root/nym-client
COPY --from=builder /root/nym/target/release/nym-network-requester /root/nym-network-requester

WORKDIR /root

COPY ./1_fg_init.sh .
COPY ./2_bg_start.sh .

RUN chown -R root:root /root \
    && chmod 0700 /root/nym-client \
    && chmod 0700 /root/nym-network-requester \
    && chmod 0700 /root/1_fg_init.sh \
    && chmod 0700 /root/2_bg_start.sh

RUN ls -lah /root
