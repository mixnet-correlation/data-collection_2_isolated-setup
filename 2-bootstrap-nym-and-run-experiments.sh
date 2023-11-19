#!/usr/bin/env bash


# Safety settings.
set -euo pipefail
shopt -s failglob


### MODIFY BEGIN ###

# Specify git tag of the compiled Nym sources to use.
mixcorr_nym_gittag="nym-binaries-1.0.2"

# Parent directory of where the results directory of this script will be created.
mixcorr_res_dir_root="/root/mixcorr/data-collection_results"

# Define the filesystem location of the experiment scenarios repository.
mixcorr_scens_dir="/root/mixcorr/data-collection_1_experiments"

# Specify short identifier of the experiment in the scenarios repository to run.
export mixcorr_exp_id="exp01"

# Supply name of the experiment in the scenarios repository to run.
mixcorr_exp_name="${mixcorr_exp_id}_${mixcorr_nym_gittag}_static-http-download"

# Specify the total number of single experiments to be conducted by this script.
mixcorr_exp_runs_target=5000

# Specify the number of characters in the static file (i.e., its size) to be generated
# at the start of each experiment run that will be downloaded by all curl clients on the
# respective other endpoints instance. The final file will be 10 characters shorter that
# will be filled with the run-respective ID.
# Set to: 1 MiB.
mixcorr_exp_static_file_http_chars_num=1048576

### MODIFY END ###


# Capture date of invoking this script, create target folder and log file.
ts_fmt="+%Y-%m-%d_%H-%M-%S"
run_time=$( date "${ts_fmt}" )

# Define output directory for this experiment.
instance_hostname=$( uname --nodename )
export mixcorr_res_dir="${mixcorr_res_dir_root}/${run_time}_${instance_hostname}_${mixcorr_exp_name}"
mkdir -p "${mixcorr_res_dir}"

log_file="${mixcorr_res_dir}/logs_2-bootstrap-nym-and-run-experiments.log"
touch "${log_file}"

cp "${0}" "${mixcorr_res_dir}/" &>> "${log_file}"


# Logs line (arg 1) to STDOUT and log file prefixed with
# the current timestamp (YYYY/MM/DD_HH:MM:SS.NNNNNNNNN).
ts_log="+%Y/%m/%d_%H:%M:%S.%N"
log_ts () {
    ts=$( date "${ts_log}" )
    printf "[${ts}] ${1}\n"
    printf "[${ts}] ${1}\n" &>> "${log_file}"
}


log_ts "Script '2-bootstrap-nym-and-run-experiments.sh' invoked with the following variables:"
log_ts "    - run_time='${run_time}'"
log_ts "    - log_file='${log_file}'"
log_ts "    - mixcorr_exp_id='${mixcorr_exp_id}'"
log_ts "    - mixcorr_nym_gittag='${mixcorr_nym_gittag}'"
log_ts "    - mixcorr_res_dir_root='${mixcorr_res_dir_root}'"
log_ts "    - mixcorr_res_dir='${mixcorr_res_dir}'"
log_ts "    - mixcorr_scens_dir='${mixcorr_scens_dir}'"
log_ts "    - mixcorr_exp_name='${mixcorr_exp_name}'"
log_ts "    - mixcorr_exp_runs_target='${mixcorr_exp_runs_target}'"
log_ts "    - mixcorr_exp_static_file_http_chars_num='${mixcorr_exp_static_file_http_chars_num}'"
printf "\n" &>> "${log_file}"


log_ts "Logging various hardware information about experiment machine..."
printf "\n" &>> "${log_file}"
uname -a &>> "${log_file}"
printf "\n" &>> "${log_file}"
lscpu &>> "${log_file}"
printf "\n" &>> "${log_file}"
lshw -short -sanitize &>> "${log_file}"
printf "\n" &>> "${log_file}"


# Prepare environment for gateway patch.
export mixcorr_gateway_sphinxflow_dir="${mixcorr_res_dir}/gateway_sphinxflows"
mkdir -p "${mixcorr_gateway_sphinxflow_dir}" &>> "${log_file}"


# Make sure this repository does not contain any leftover or uncommitted changes before starting.
log_ts "Removing any potentially still present changes from this repository..."
git status &>> "${log_file}"
printf "\n" &>> "${log_file}"
git clean -fdx &>> "${log_file}"
printf "\n" &>> "${log_file}"
git status &>> "${log_file}"
printf "\n" &>> "${log_file}"


# Make sure all patches are available in the respective Dockerfile directories.
log_ts "Making sure ${mixcorr_scens_dir} is set correctly and syncing relevant patches..."
( cd "${mixcorr_scens_dir}" && git checkout main && git reset --hard && git pull && git status ) &>> "${log_file}"
rsync -av --exclude="README.md" "${mixcorr_scens_dir}/${mixcorr_exp_name}/" ./ &>> "${log_file}"
printf "\n" &>> "${log_file}"


log_ts "Copying current folder and files structure to result folder..."
rsync -av --exclude={".git","LICENSE","README.md"} ./ "${mixcorr_res_dir}/" &>> "${log_file}"
printf "\n" &>> "${log_file}"


# Build all Docker images such that we can start them instantly afterwards.

log_ts "Now building Docker image 'mixmatch/nym-validator:v27.0' (this may take a while)..."
( cd ./validator && docker build \
    --build-arg mixcorr_nym_gittag="${mixcorr_nym_gittag}" \
    -t mixmatch/nym-validator:v27.0 . > "${mixcorr_res_dir}/logs_docker-build_validator.log" 2>&1 ) &>> "${log_file}"

log_ts "Now building Docker image 'mixmatch/nym-busybox:v1.0.0' (this may take a while)..."
( cd ./busybox && docker build \
    --build-arg mixcorr_nym_gittag="${mixcorr_nym_gittag}" \
    -t mixmatch/nym-busybox:v1.0.0 . > "${mixcorr_res_dir}/logs_docker-build_busybox.log" 2>&1 ) &>> "${log_file}"

log_ts "Now building Docker image 'mixmatch/nym-validator-api:v1.0.1-new' (this may take a while)..."
( cd ./validator-api && docker build \
    --build-arg mixcorr_nym_gittag="${mixcorr_nym_gittag}" \
    -t mixmatch/nym-validator-api:v1.0.1-new . > "${mixcorr_res_dir}/logs_docker-build_validator-api.log" 2>&1 ) &>> "${log_file}"

log_ts "Now building Docker image 'mixmatch/nym-gateway:nym-binaries-1.0.2' (this may take a while)..."
( cd ./gateway && docker build \
    --build-arg mixcorr_nym_gittag="${mixcorr_nym_gittag}" \
    -t mixmatch/nym-gateway:nym-binaries-1.0.2 . > "${mixcorr_res_dir}/logs_docker-build_gateway.log" 2>&1 ) &>> "${log_file}"

log_ts "Now building Docker image 'mixmatch/nym-mixnode:nym-binaries-1.0.2' (this may take a while)..."
( cd ./mixnode && docker build \
    --build-arg mixcorr_nym_gittag="${mixcorr_nym_gittag}" \
    -t mixmatch/nym-mixnode:nym-binaries-1.0.2 . > "${mixcorr_res_dir}/logs_docker-build_mixnode.log" 2>&1 ) &>> "${log_file}"

log_ts "Now building Docker image 'mixmatch/nym-client-requester-server:nym-binaries-1.0.2' (this may take a while)..."
( cd ./client_requester_server && docker build \
    --build-arg mixcorr_nym_gittag="${mixcorr_nym_gittag}" \
    -t mixmatch/nym-client-requester-server:nym-binaries-1.0.2 . > "${mixcorr_res_dir}/logs_docker-build_client-requester-server.log" 2>&1 ) &>> "${log_file}"

log_ts "Now building Docker image 'mixmatch/nym-socks5-client:nym-binaries-1.0.2' (this may take a while)..."
( cd ./socks5-client && docker build \
    --build-arg mixcorr_nym_gittag="${mixcorr_nym_gittag}" \
    -t mixmatch/nym-socks5-client:nym-binaries-1.0.2 . > "${mixcorr_res_dir}/logs_docker-build_socks5-client.log" 2>&1 ) &>> "${log_file}"
printf "\n" &>> "${log_file}"



log_ts "Generating $(( ${mixcorr_exp_static_file_http_chars_num} - 10 )) random characters for experiment document of size ${mixcorr_exp_static_file_http_chars_num} Bytes (10 remaining characters will be run-specific ID)..."
( pwgen -sync $(( ${mixcorr_exp_static_file_http_chars_num} - 10 )) 1 > "${mixcorr_res_dir}/document_to_download.txt" ) &>> "${log_file}"
truncate -s -1 "${mixcorr_res_dir}/document_to_download.txt" &>> "${log_file}"
ls -la "${mixcorr_res_dir}/document_to_download.txt" &>> "${log_file}"

exp_runs_successful=0
exp_runs_attempted=1
run_init_failure="no"

while (( "${exp_runs_successful}" < "${mixcorr_exp_runs_target}" )); do


    # Spawn all parts of the bootstrapped Nym network.


    # Validator.

    log_ts "Starting up the nym_validator Docker image via Docker Compose now..."
    docker compose -f ./1_compose_validator.yaml up -d &>> "${mixcorr_res_dir}/logs_docker-run_validator.log"
    sleep 1

    log_ts "Running initialization script for nym_validator now..."
    docker exec nym_validator bash -c "/root/1_fg_init.sh genesis" &>> "${mixcorr_res_dir}/logs_docker-run_validator.log"
    sleep 1

    ( docker exec nym_validator bash -c "/root/2_bg_start.sh" & ) &>> "${mixcorr_res_dir}/logs_docker-run_validator.log"
    sleep 15

    docker exec nym_validator bash -c "/root/3_fg_send_funds.sh" &>> "${mixcorr_res_dir}/logs_docker-run_validator.log"
    log_ts "All nym_validator scripts completed!"
    printf "\n" &>> "${log_file}"


    # Busybox.

    log_ts "Starting up the nym_busybox Docker image via Docker Compose now..."
    docker compose -f ./2_compose_busybox.yaml up -d &>> "${mixcorr_res_dir}/logs_docker-run_busybox.log"
    sleep 1

    log_ts "Running nym_busybox scripts for contract uploading and initializing the mixnet contract now..."

    docker exec \
        --env "CONTRACT_UPLOADER=contract_uploader" \
        --env-file "./nym_env_variables.env" \
        nym_busybox \
        bash -c "/root/scripts/upload_contract.sh" &>> "${mixcorr_res_dir}/logs_docker-run_busybox.log"
    sleep 5

    docker exec \
        --env "CODE_ID=1" \
        --env "CONTRACT_OWNER=mixnet_contract_owner" \
        --env-file "./nym_env_variables.env" \
        nym_busybox \
        bash -c "/root/scripts/init_mixnet_contract.sh" &>> "${mixcorr_res_dir}/logs_docker-run_busybox.log"
    sleep 5
    log_ts "All nym_busybox scripts completed!"
    printf "\n" &>> "${log_file}"


    # Validator API.

    log_ts "Starting up the nym_validator_api Docker image via Docker Compose now..."
    docker compose -f ./3_compose_validatorapi.yaml up -d &>> "${mixcorr_res_dir}/logs_docker-run_validator-api.log"
    sleep 1

    log_ts "Running initialization script for nym_validator_api now..."
    docker exec nym_validator_api bash -c "/root/1_fg_init.sh" &>> "${mixcorr_res_dir}/logs_docker-run_validator-api.log"
    sleep 2

    ( docker exec nym_validator_api bash -c "/root/2_bg_start.sh" & ) &>> "${mixcorr_res_dir}/logs_docker-run_validator-api.log"
    sleep 5
    log_ts "All nym_validator_api scripts completed!"
    printf "\n" &>> "${log_file}"


    # Gateway and mixnodes.

    log_ts "Starting up nym_gateway and nym_mixnode Docker images via Docker Compose now..."
    docker compose -f ./4_compose_gateway-mixnodes.yaml up -d &>> "${mixcorr_res_dir}/logs_docker-run_gateway-mixnodes.log"
    sleep 1

    log_ts "Running initialization script for nym_gateway now..."
    docker exec nym_gateway bash -c "/root/1_fg_init.sh" &>> "${mixcorr_res_dir}/logs_docker-run_gateway-mixnodes.log"
    ( docker exec nym_gateway bash -c "/root/2_bg_start.sh" & ) &>> "${mixcorr_res_dir}/logs_docker-run_gateway-mixnodes.log"
    sleep 5
    log_ts "All nym_gateway scripts completed!"
    printf "\n" &>> "${log_file}"


    log_ts "Running initialization script for nym_mixnode_one now..."
    docker exec nym_mixnode_one bash -c "/root/1_fg_init.sh" &>> "${mixcorr_res_dir}/logs_docker-run_gateway-mixnodes.log"
    ( docker exec nym_mixnode_one bash -c "/root/2_bg_start.sh" & ) &>> "${mixcorr_res_dir}/logs_docker-run_gateway-mixnodes.log"
    sleep 1

    log_ts "Running initialization script for nym_mixnode_two now..."
    docker exec nym_mixnode_two bash -c "/root/1_fg_init.sh" &>> "${mixcorr_res_dir}/logs_docker-run_gateway-mixnodes.log"
    ( docker exec nym_mixnode_two bash -c "/root/2_bg_start.sh" & ) &>> "${mixcorr_res_dir}/logs_docker-run_gateway-mixnodes.log"
    sleep 1

    log_ts "Running initialization script for nym_mixnode_three now..."
    docker exec nym_mixnode_three bash -c "/root/1_fg_init.sh" &>> "${mixcorr_res_dir}/logs_docker-run_gateway-mixnodes.log"
    ( docker exec nym_mixnode_three bash -c "/root/2_bg_start.sh" & ) &>> "${mixcorr_res_dir}/logs_docker-run_gateway-mixnodes.log"
    sleep 10

    log_ts "All nym_mixnode scripts completed!"
    printf "\n" &>> "${log_file}"


    log_ts "Running busybox job that bonds all mixnodes..."
    docker exec \
        --env-file "./nym_env_variables.env" \
        nym_busybox \
        bash -c "/root/scripts/bond_minimal_mixnode_topology.sh" &>> "${mixcorr_res_dir}/logs_docker-run_busybox.log"
    sleep 2

    log_ts "Running busybox job that bonds the gateway..."
    docker exec \
        --env-file "./nym_env_variables.env" \
        nym_busybox \
        bash -c "/root/scripts/bond_minimal_gateway_topology.sh" &>> "${mixcorr_res_dir}/logs_docker-run_busybox.log"
    sleep 5
    printf "\n" &>> "${log_file}"


    log_ts "Waiting for bootstrapped Nym network to be ready for client use (this may take a while)..."
    epoch_current=$( ( curl -s -X "GET" -H "accept: application/json" "http://127.0.0.1:8080/v1/epoch/current" | grep -e "\"id\":0," ) || true )

    while [[ -n "${epoch_current}" ]];
    do
        sleep 10
        epoch_current=$( ( curl -s -X "GET" -H "accept: application/json" "http://127.0.0.1:8080/v1/epoch/current" | grep -e "\"id\":0," ) || true )
    done

    log_ts "Bootstrapped Nym network now has a routable topology and is ready for client use!"
    printf "\n" &>> "${log_file}"
    sleep 5


    log_ts "Logging current epoch (queried at nym_validator_api)..."
    ( curl -s -X "GET" -H "accept: application/json" "http://127.0.0.1:8080/v1/epoch/current" | jq . ) &>> "${log_file}"
    printf "\n\n" &>> "${log_file}"

    log_ts "Logging known gateways (queried at nym_validator_api)..."
    ( curl -s -X "GET" -H "accept: application/json" "http://127.0.0.1:8080/v1/gateways" | jq . ) &>> "${log_file}"
    printf "\n\n" &>> "${log_file}"

    log_ts "Logging known mixnodes (queried at nym_validator_api)..."
    ( curl -s -X "GET" -H "accept: application/json" "http://127.0.0.1:8080/v1/mixnodes/detailed" | jq . ) &>> "${log_file}"
    printf "\n\n" &>> "${log_file}"


    while (( "${exp_runs_successful}" < "${mixcorr_exp_runs_target}" )); do

        printf -v mixcorr_exp_run "%05d" "${exp_runs_attempted}"
        export mixcorr_exp_run

        printf "\n" &>> "${log_file}"
        log_ts "[run#${mixcorr_exp_run}] Attempting experiment run ${mixcorr_exp_run}..."

        run_res_dir="${mixcorr_res_dir}/${mixcorr_exp_id}_curl_run_${mixcorr_exp_run}"
        log_ts "[run#${mixcorr_exp_run}] Creating result folder ${run_res_dir} for this run..."
        mkdir -p "${run_res_dir}"

        log_ts "[run#${mixcorr_exp_run}] Starting up the Docker image via Docker Compose for nym_client_requester_server_${mixcorr_exp_run}..."
        docker compose -f ./5_compose_client-requester-server.yaml up -d &>> "${run_res_dir}/logs_docker-run_client-requester-server_${mixcorr_exp_run}.log"
        sleep 1

        log_ts "[run#${mixcorr_exp_run}] Running initialization script for nym_client_requester_server_${mixcorr_exp_run} now..."
        ( docker exec "nym_client_requester_server_${mixcorr_exp_run}" bash -c "/root/1_fg_init.sh" || true ) &>> "${run_res_dir}/logs_docker-run_client-requester-server_${mixcorr_exp_run}.log"
        sleep 2

        # Try to detect if the validator-api has crashed so that we may recover by restarting everything.
        if [[ $( grep -c "thread 'main' panicked" "${run_res_dir}/logs_docker-run_client-requester-server_${mixcorr_exp_run}.log" ) -gt 0 ]] && [[ $( grep -c "ValidatorAPIError" "${run_res_dir}/logs_docker-run_client-requester-server_${mixcorr_exp_run}.log" ) -gt 0 ]]; then
            run_init_failure="One endpoint initialization process of this run failed due to the validator-api being unavailable"
            break
        fi

        ( docker exec "nym_client_requester_server_${mixcorr_exp_run}" bash -c "/root/2_bg_start.sh" & ) &>> "${run_res_dir}/logs_docker-run_client-requester-server_${mixcorr_exp_run}.log"
        sleep 5
        log_ts "[run#${mixcorr_exp_run}] All scripts for nym_client_requester_server_${mixcorr_exp_run} completed!"


        log_ts "[run#${mixcorr_exp_run}] Starting up the Docker image via Docker Compose for nym_socks5client_${mixcorr_exp_run}..."
        docker compose -f ./6_compose_socks5client.yaml up -d &>> "${run_res_dir}/logs_docker-run_socks5client_${mixcorr_exp_run}.log"
        sleep 1

        log_ts "[run#${mixcorr_exp_run}] Running initialization script for nym_socks5client_${mixcorr_exp_run} now..."
        ( docker exec "nym_socks5client_${mixcorr_exp_run}" bash -c "/root/1_fg_init.sh" || true ) &>> "${run_res_dir}/logs_docker-run_socks5client_${mixcorr_exp_run}.log"
        sleep 2

        # Try to detect if the validator-api has crashed so that we may recover by restarting everything.
        if [[ $( grep -c "thread 'main' panicked" "${run_res_dir}/logs_docker-run_socks5client_${mixcorr_exp_run}.log" ) -gt 0 ]] && [[ $( grep -c "ValidatorAPIError" "${run_res_dir}/logs_docker-run_socks5client_${mixcorr_exp_run}.log" ) -gt 0 ]]; then
            run_init_failure="One endpoint initialization process of this run failed due to the validator-api being unavailable"
            break
        fi

        ( docker exec "nym_socks5client_${mixcorr_exp_run}" bash -c "/root/2_bg_start.sh" & ) &>> "${run_res_dir}/logs_docker-run_socks5client_${mixcorr_exp_run}.log"
        sleep 5
        log_ts "[run#${mixcorr_exp_run}] All scripts for nym_socks5client_${mixcorr_exp_run} completed!"


        log_ts "[run#${mixcorr_exp_run}] Downloading target HTTP file via nym_socks5client_${mixcorr_exp_run} now..."
        ( docker exec "nym_socks5client_${mixcorr_exp_run}" bash -c "/root/3_fg_run_${mixcorr_exp_id}.sh" || true ) &>> "${run_res_dir}/logs_docker-run_socks5client_${mixcorr_exp_run}.log"
        log_ts "[run#${mixcorr_exp_run}] Download of run ${mixcorr_exp_run} completed or aborted (successful download check pending)!"
        sleep 1


        # Copy /root/.nym folder from both clients to experiment results folder.
        log_ts "[run#${mixcorr_exp_run}] Saving .nym folders from both clients now..."
        docker exec "nym_client_requester_server_${mixcorr_exp_run}" bash -c "rsync -av /root/.nym/ /root/data/${mixcorr_exp_id}_curl_run_${mixcorr_exp_run}/client_nym_folder" &>> "${run_res_dir}/logs_docker-run_client-requester-server_${mixcorr_exp_run}.log"
        docker exec "nym_socks5client_${mixcorr_exp_run}" bash -c "rsync -av /root/.nym/ /root/data/${mixcorr_exp_id}_curl_run_${mixcorr_exp_run}/socks5client_nym_folder" &>> "${run_res_dir}/logs_docker-run_socks5client_${mixcorr_exp_run}.log"


        # Stop both client containers in order to spawn new ones for the next run.
        log_ts "[run#${mixcorr_exp_run}] Stopping client containers after download concluded..."
        docker compose -f ./5_compose_client-requester-server.yaml stop &>> "${run_res_dir}/logs_docker-run_client-requester-server_${mixcorr_exp_run}.log"
        docker compose -f ./5_compose_client-requester-server.yaml rm --force &>> "${run_res_dir}/logs_docker-run_client-requester-server_${mixcorr_exp_run}.log"
        docker compose -f ./6_compose_socks5client.yaml stop &>> "${run_res_dir}/logs_docker-run_socks5client_${mixcorr_exp_run}.log"
        docker compose -f ./6_compose_socks5client.yaml rm --force &>> "${run_res_dir}/logs_docker-run_socks5client_${mixcorr_exp_run}.log"


        log_ts "[run#${mixcorr_exp_run}] Verifying whether experiment download was a success..."

        file_client="${run_res_dir}/curl_client_directory/document.txt"
        file_webserver="${run_res_dir}/webserver_directory/document.txt"
        client_log_success=$( grep -c "Proxy for 127.0.0.1:9909 is finished" "${run_res_dir}/logs_docker-run_client-requester-server_${mixcorr_exp_run}.log" )
        socks5client_log_success=$( grep -c "Proxy for 127.0.0.1:9909 is finished" "${run_res_dir}/logs_docker-run_socks5client_${mixcorr_exp_run}.log" )

        cur_run_successful="no"
        if [[ "${client_log_success}" -eq 1 ]] && [[ "${socks5client_log_success}" -eq 1 ]]; then

            if cmp --silent "${file_client}" "${file_webserver}"; then
                log_ts "[run#${mixcorr_exp_run}] Download successful, files match!"
                ( sha512sum "${file_client}" "${file_webserver}" >> "${run_res_dir}/SUCCEEDED" ) &>> "${log_file}"
                printf "\n" >> "${run_res_dir}/SUCCEEDED"
                cur_run_successful="yes"
            else
                log_ts "[run#${mixcorr_exp_run}] Download failed, files don't match!"
                ( sha512sum "${file_client}" "${file_webserver}" >> "${run_res_dir}/FAILED" ) &>> "${log_file}"
                printf "\n" >> "${run_res_dir}/FAILED"
            fi
        else
            log_ts "[run#${mixcorr_exp_run}] Download failed, proxy did not even complete!"
            printf "Proxy between curl=>nym-socks5-client and nym-client=>network-requester=>webserver did not complete\n" >> "${run_res_dir}/FAILED"
        fi
        printf "\n" >> "${log_file}"

        if [[ "${cur_run_successful}" == "yes" ]]; then
            exp_runs_successful=$(( "${exp_runs_successful}" + 1 ))
        fi


        log_ts "[run#${mixcorr_exp_run}] We have run ${exp_runs_attempted} so far, of which ${exp_runs_successful} have been successful. Our target number of successful runs is ${mixcorr_exp_runs_target} ($(( ${mixcorr_exp_runs_target} - ${exp_runs_successful} )) to go)."

        # Increment the run counters.
        exp_runs_attempted=$(( "${exp_runs_attempted}" + 1 ))

    done

    if [[ "${run_init_failure}" != "no" ]]; then

        printf "\n" >> "${log_file}"
        log_ts "[run#${mixcorr_exp_run}] WARNING: The validator-api crashed! Restarting everything and trying again to reach ${mixcorr_exp_runs_target} successful experiment runs..."
        printf "\n" >> "${log_file}"

        docker compose -f ./1_compose_validator.yaml down --remove-orphans &>> "${log_file}"

        # Make sure to mark this run as a FAILED attempt and increment the attempts counter.
        printf "${run_init_failure}\n" >> "${run_res_dir}/FAILED"
        exp_runs_attempted=$(( "${exp_runs_attempted}" + 1 ))

        docker compose -f ./1_compose_validator.yaml down --remove-orphans &>> "${log_file}"
        run_init_failure="no"

        sleep 5

    fi

done


log_ts "We have conducted ${mixcorr_exp_runs_target} successful experiment runs, shutting down all containers now..."
docker compose -f ./1_compose_validator.yaml down --remove-orphans &>> "${log_file}"


log_ts "Removing earlier copied patches from ${mixcorr_scens_dir}/${mixcorr_exp_name} again..."
git status &>> "${log_file}"
printf "\n" &>> "${log_file}"
git clean -fdx &>> "${log_file}"
printf "\n" &>> "${log_file}"
git status &>> "${log_file}"
printf "\n" &>> "${log_file}"


log_ts "Clean up completed, we're done. Exiting."
