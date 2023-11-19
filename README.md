# Bootstrapped-Nym Data Collection on Hetzner

Dataset collection orchestrator in the Isolated Setup for PoPETs 2024.2 paper "MixMatch: Flow Matching for Mixnet Traffic".

We assume you are using the public cloud provider Hetzner as the place to run the cloud instances used to collect data in the Isolated Setup. Thus, the first script [`1-provision-hetzner-base-nym-data-collection.sh`](./1-provision-hetzner-base-nym-data-collection.sh) assumes the `hcloud` command-line utility to be installed and authenticated against a Hetzner Cloud account. Please ensure that is the case, for example, by following the instructions on this page: [github.com/hetznercloud/cli](https://github.com/hetznercloud/cli). It should be straightforward to translate the logic behind [`1-provision-hetzner-base-nym-data-collection.sh`](./1-provision-hetzner-base-nym-data-collection.sh) to alternative cloud providers or even local-only setups. Going forward, we assume that `hcloud` is installed and configured.


## Setting Up and Collecting a Dataset

The following steps will create a small Hetzner instance and provision it:
```bash
root@ubuntu2204 $   mkdir -p ~/mixmatch
root@ubuntu2204 $   cd ~/mixmatch
root@ubuntu2204 $   git clone https://github.com/mixnet-correlation/data-collection_2_isolated-setup.git
root@ubuntu2204 $   cd data-collection_2_isolated-setup
root@ubuntu2204 $   ./1-provision-hetzner-base-nym-data-collection.sh
```

At this point, check that the contents of the log file make sense to you, power down the instance, and take a snapshot of it.

Next, via the web interface of your cloud provider (Hetzner, in our case), create the desired number of instances based on the previously taken snapshot to run in parallel and that in aggregation amount to the total number of flow pairs to collect (per instance target number of flow pairs to collect: `mixcorr_exp_runs_target` at the top of [`2-bootstrap-nym-and-run-experiments.sh`](./2-bootstrap-nym-and-run-experiments.sh)).

In turn, SSH into each created instance, make sure the configuration values at the top of [`2-bootstrap-nym-and-run-experiments.sh`](./2-bootstrap-nym-and-run-experiments.sh) are adjusted to your intended data collection scenario and run:
```bash
root@collector_instance_X $   tmux
root@collector_instance_X $   /root/mixcorr/data-collection_2_isolated-setup/2-bootstrap-nym-and-run-experiments.sh
```

Once all scripts have concluded, make sure to download the result folders (located at `mixcorr_res_dir` as defined as part of [`2-bootstrap-nym-and-run-experiments.sh`](./2-bootstrap-nym-and-run-experiments.sh)) from each cloud instance.


## Licensing and Copyright Information

We make this project available under the [GPLv3 license](./LICENSE). However, this repository contains the following files that are either entirely authored by the [Nym team](https://nymtech.net/) (our thanks in particular to Tommy Verrall) or their original work but modified by us, and licensed under the [Apache 2.0 license](./Apache-2.0.txt):
* [`./busybox/Dockerfile`](./busybox/Dockerfile)
* [`./busybox/envs/local.env`](./busybox/envs/local.env)
* [`./busybox/mixnet_contract.wasm`](./busybox/mixnet_contract.wasm)
* [`./busybox/scripts/bond_gateway.sh`](./busybox/scripts/bond_gateway.sh)
* [`./busybox/scripts/bond_minimal_gateway_topology.sh`](./busybox/scripts/bond_minimal_gateway_topology.sh)
* [`./busybox/scripts/bond_minimal_mixnode_topology.sh`](./busybox/scripts/bond_minimal_mixnode_topology.sh)
* [`./busybox/scripts/bond_mixnode.sh`](./busybox/scripts/bond_mixnode.sh)
* [`./busybox/scripts/create_vesting_schedules.sh`](./busybox/scripts/create_vesting_schedules.sh)
* [`./busybox/scripts/init_mixnet_contract.sh`](./busybox/scripts/init_mixnet_contract.sh)
* [`./busybox/scripts/init_vesting_contract.sh`](./busybox/scripts/init_vesting_contract.sh)
* [`./busybox/scripts/upload_contract.sh`](./busybox/scripts/upload_contract.sh)
* [`./busybox/scripts/vesting_bond_gateway.sh`](./busybox/scripts/vesting_bond_gateway.sh)
* [`./busybox/scripts/vesting_bond_mixnode.sh`](./busybox/scripts/vesting_bond_mixnode.sh)
* [`./busybox/validator-client-scripts`](./busybox/validator-client-scripts)
* [`./busybox/vesting_contract.wasm`](./busybox/vesting_contract.wasm)
* [`./gateway/1_fg_init.sh`](./gateway/1_fg_init.sh)
* [`./gateway/Dockerfile`](./gateway/Dockerfile)
* [`./mixnode/1_fg_init.sh`](./mixnode/1_fg_init.sh)
* [`./mixnode/Dockerfile`](./mixnode/Dockerfile)
* [`./nym_env_variables.env`](./nym_env_variables.env)
* [`./validator/1_fg_init.sh`](./validator/1_fg_init.sh)
* [`./validator/3_fg_send_funds.sh`](./validator/3_fg_send_funds.sh)
* [`./validator/Dockerfile`](./validator/Dockerfile)
* [`./validator-api/1_fg_init.sh`](./validator-api/1_fg_init.sh)
* [`./validator-api/Dockerfile`](./validator-api/Dockerfile)
