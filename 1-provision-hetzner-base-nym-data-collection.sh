#!/usr/bin/env bash


# Safety settings.
set -euo pipefail
shopt -s failglob


### MODIFY BEGIN ###

server_type="cpx11"
server_name="mixcorr-nym-${server_type}"
server_location="nbg1"
server_image="ubuntu-22.04"
read -p "[${server_name}] Specify name of Hetzner firewall to apply to this instance: " server_firewall
read -p "[${server_name}] Specify name of SSH key as stored on Hetzner to use for access to instance: " server_sshkey
printf "\n\n"

server_root_dir="/root/mixcorr"
server_orchestration_repo="https://github.com/mixnet-correlation/data-collection_2_isolated-setup.git"
server_orchestration_dir="${server_root_dir}/data-collection_2_isolated-setup"
server_scens_repo="https://github.com/mixnet-correlation/data-collection_1_experiments.git"
server_scens_dir="${server_root_dir}/data-collection_1_experiments"

### MODIFY END ###


# Capture time of invoking this script and generate log file name.
ts_file="+%Y_%m_%d_%H_%M_%S"
run_time=$(date "${ts_file}")
log_file="${run_time}_script_1-provision-hetzner-base-nym-data-collection.log"
touch "${log_file}"

# Logs line (arg 1) to STDOUT and log file prefixed with
# the current timestamp (YYYY/MM/DD_HH:MM:SS.NNNNNNNNN).
ts_log="+%Y/%m/%d_%H:%M:%S.%N"
log_ts () {
    ts=$(date "${ts_log}")
    printf "[${ts}] ${1}\n"
    printf "[${ts}] ${1}\n\n" >> "${log_file}"
}


### MAIN PROCEDURE START: PROVISION BASE DATA COLLECTION MACHINE FOR SNAPSHOT ###

log_ts "Creating instance..."
hcloud server create \
    --start-after-create \
    --name "${server_name}" \
    --type "${server_type}" \
    --location "${server_location}" \
    --image "${server_image}" \
    --firewall "${server_firewall}" \
    --ssh-key "${server_sshkey}" &>> "${log_file}"
printf "\n" >> "${log_file}"

sleep 15

server_ip=$(hcloud server ip "${server_name}") &>> "${log_file}"
log_ts "Created instance with IP ${server_ip}"

log_ts "Replacing entries for ${server_ip} in your ~/.ssh/known_hosts with the new values to avoid authenticity warnings..."
ssh-keygen -R "${server_ip}" &>> "${log_file}"
ssh-keyscan -t ed25519 "${server_ip}" &>> "${log_file}" >> ~/.ssh/known_hosts
printf "\n" >> "${log_file}"

sleep 1

log_ts "Updating and upgrading..."
hcloud server ssh "${server_name}" "DEBIAN_FRONTEND=noninteractive apt-get update --yes" &>> "${log_file}"
sleep 1
printf "\n" >> "${log_file}"
hcloud server reboot "${server_name}" &>> "${log_file}"
sleep 15
printf "\n" >> "${log_file}"
hcloud server ssh "${server_name}" "DEBIAN_FRONTEND=noninteractive apt-get upgrade --yes --with-new-pkgs" &>> "${log_file}"
hcloud server ssh "${server_name}" "DEBIAN_FRONTEND=noninteractive apt-get autoremove --yes --purge" &>> "${log_file}"
hcloud server ssh "${server_name}" "DEBIAN_FRONTEND=noninteractive apt-get clean --yes" &>> "${log_file}"
hcloud server ssh "${server_name}" "chown -R root:root /root && chmod 0700 /root/.ssh && chmod 0600 /root/.ssh/authorized_keys" &>> "${log_file}"
sleep 1
printf "\n" >> "${log_file}"
hcloud server reboot "${server_name}" &>> "${log_file}"
sleep 15
printf "\n\n" >> "${log_file}"

log_ts "Installing packages..."
hcloud server ssh "${server_name}" "DEBIAN_FRONTEND=noninteractive apt-get install --yes pkg-config build-essential util-linux ca-certificates gnupg libssl-dev apt-transport-https software-properties-common lsb-release lshw util-linux curl jq pwgen htop tree tmux git python3-pip" &>> "${log_file}"
sleep 1
printf "\n" >> "${log_file}"
hcloud server reboot "${server_name}" &>> "${log_file}"
sleep 15
printf "\n\n" >> "${log_file}"

sleep 1

log_ts "Installing docker..."
hcloud server ssh "${server_name}" "mkdir -p /etc/apt/keyrings" &>> "${log_file}"
hcloud server ssh "${server_name}" "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg" &>> "${log_file}"
hcloud server ssh "${server_name}" 'echo "deb [arch=$( dpkg --print-architecture ) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $( lsb_release -cs ) stable" | tee /etc/apt/sources.list.d/docker.list' &>> "${log_file}"
printf "\n" >> "${log_file}"
hcloud server ssh "${server_name}" "DEBIAN_FRONTEND=noninteractive apt-get update --yes" &>> "${log_file}"
hcloud server ssh "${server_name}" "DEBIAN_FRONTEND=noninteractive apt-get install --yes docker-ce docker-ce-cli containerd.io docker-compose-plugin" &>> "${log_file}"
printf "\n" >> "${log_file}"

sleep 1

hcloud server reboot "${server_name}" &>> "${log_file}"
sleep 15
printf "\n" >> "${log_file}"

log_ts "Creating root directory ${server_root_dir} for experiments and showing contents (tree -a)..."
hcloud server ssh "${server_name}" "cd && mkdir -p ${server_root_dir} && ls -lah /root && tree -a ${server_root_dir}" &>> "${log_file}"
printf "\n" >> "${log_file}"

log_ts "Cloning orchestration repository into ${server_root_dir} and showing contents (tree -a)..."
hcloud server ssh "${server_name}" "cd ${server_root_dir} && git clone ${server_orchestration_repo} ${server_orchestration_dir} && tree -a ${server_root_dir}" &>> "${log_file}"
printf "\n" >> "${log_file}"

log_ts "Cloning scenarios repository into ${server_root_dir} and showing contents (tree -a)..."
hcloud server ssh "${server_name}" "cd ${server_root_dir} && git clone ${server_scens_repo} ${server_scens_dir} && tree -a ${server_root_dir}" &>> "${log_file}"
printf "\n" >> "${log_file}"

### MAIN PROCEDURE END ###


log_ts "Done!"
