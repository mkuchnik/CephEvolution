# Experiments
This document describes how to run the experiments contained in the submission.
There are two logical groups of experiments: with and without a cluster
deployment.
Figure 3 is a simulation, and therefore does not require a cluster.
The rest of the figures utilize a 16 node Ceph cluster with either a HDD or SSD
(specifically NVMe) backing the Ceph OSDs.
Replicating the cluster setup is the most challenging part of running these
experiments --- once a cluster is setup, the benchmarking scripts are relatively
easy to use.

## Benchmark tools
We make use of Ceph benchmarking tools.
A guide covering these is [here](https://tracker.ceph.com/projects/ceph/wiki/Benchmark_Ceph_Cluster_Performance).
In general, you should be able to tell how we ran the tools just by referencing
the scripts we created for those tests.

## Cluster Deployment
The experiments were originally run using [ceph-deploy](https://docs.ceph.com/docs/master/rados/deployment/).
However, we also include a
[ceph-ansible](https://docs.ceph.com/ceph-ansible/master/installation/methods.html) setup that should reproduce the
results (found in the `ceph-ansible` directory).
Ceph-ansible has a steeper learning curve than ceph-deploy, so it may make sense
to start with ceph-deploy (on a small cluster) and then switch to ceph-ansible
once you understand the deployment process.

### Ceph-Ansible
To deploy with ansible, run:
```bash
./init_repo.sh
```
from the root directory.
This script has a parameter to choose SSD (NVMe) or HDD, but changing the
backend from FileStore to BlueStore requires editting the ansible configuration
(in `group_vars/all.yml` and `group_vars/osds.yml`).
The `Ceph_Deploy_Install_Scripts` directory contains ceph-deploy scripts.
The changes in `group_vars/all.yml` are as follows (for filestore, you want XFS
options, too):
![Backend_Edit_All](Figures/Backend_Edit_All.png)

The changes in `group_vars/osds.yml` are as follows:
![Backend_Edit_OSDs](Figures/Backend_Edit_OSDs.png)

The deployment was customized to our Orca cluster.
To port the ansible install to another cluster, you'll definitely want to change
some parameters.
You should be familiar with Ansible; Ansible docs are [here](https://docs.ansible.com/ansible).
Obviously, you'll need to change the `hosts16.yml` file to create a new hosts
file to reflect the hosts you want to use as your OSDs, Monitors, and Managers.
The details of hosts files are described
[here](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html).
You can leave `site.yml` the same.
`partition_cluster_lvm.yml` has two steps.
1. It sets RCMD default to ssh and sets up an initialization needed on the Orca cluster.
For example, we update each node so they see the right hostname, and we enable
some hardware options.
We've tagged these Orca cluster specific actions as "PDL".
You can safely ignore these PDL actions for a different cluster.
2. We use [LVM](https://en.wikipedia.org/wiki/Logical_Volume_Manager_(Linux)) to create logical volumes which Ceph OSDs can place data/write ahead log (WAL).
The first half of this stage removes (wipes) the old LVMs off the system, and the second
half adds new ones.
By default, we wipe anything under the variable `all_disks`, so you'll probably
want to change that.
We then use `data_install_disks` and `wal_install_disks` to choose the disks to
use for the OSDs.
Currently, we assign both of these to a variable (`OSDDrive`) that is passed on
the command line.

You'll then need to proceed to `group_vars/all.yml`, and change things that are
not applicable to you.
I suspect these are going to be `monitor_interface` and `public_network`.
If you changed any of the LVM names in `partition_cluster_lvm.yml`, you're going
to have to reflect those changes in `group_vars/osds.yml`.
For example, we place both data and journal on the virtual group, `ceph-wal-data`, so you need to make sure you didn't change that.
The other configurations in `group_vars/` don't really use any options, so we
don't expect you'd have to change them.


### Ceph-Deploy
If using ceph-deploy, we recommend reading the documentation before running
experiments.
These can be found
[here](https://docs.ceph.com/docs/luminous/rados/deployment/).
You can find the ceph-deploy scripts in `Ceph_Deploy_Install_Scripts`.
These scripts are included just for completion.

Once your cluster is installed, you should check the status of your cluster.
```bash
ceph -s
```

The status should look something like the following:
![Ceph_Status](Figures/Ceph_Status.png)

## Figure 3 (Overhead of running object store on journaling file system)
Here we measure the overhead of running an object store on top of a journaling
file system.
We construct this benchmark in the `Journaling_Tests` directory.
To run the tests, simply run
```bash
cd Journaling_Tests
./install_deps.sh && make && ./run_test_hdd.sh && ./run_test_ssd.sh
```
We provide more comprehensive instructions in the
[Journaling_Tests/README.md](Journaling_Tests/README.md) file in that directory.


## Figure 4 (The effect of directory splitting on throughput)
Here we measure 4KiB RADOS writes with Filestore and observe that directory
splitting causes a reduction in throughput.
The scripts for running these benchmarks are in the `Cluster_Bench_Scripts/`
directory.
Scripts of the form `benchmark_micro_*` are RADOS benchmarks.
You probably want to use `benchmark_micro_write.sh`.
```bash
./benchmark_micro_write.sh 4KB
```

We provide a convenience script for plotting the RADOS data.
The benchmark script will produce a `bench_results.txt` file, which can be read
(and plotted) with this python script.
```
python3 plot_bench_results.py --paths <path-to-bench_results.txt>
```


## Figure 7 (The throughput of steady state object writes to RADOS)
Here we measure the write throughput of RADOS with Filestore compared to
BlueStore.
Throughput is evaluated at various object sizes.
The scripts for running these benchmarks are in the `Cluster_Bench_Scripts/`
directory.
Scripts of the form `benchmark_micro_*` are RADOS benchmarks.
You probably want to use `benchmark_micro_write.sh` or some wrapper of it, such
as ``bench_sweep.sh`` (a wrapper of ``benchmark_micro_all.sh``).
```bash
./bench_sweep.sh
```


## Figure 8 (The throughput of 4 KiB RADOS object writes to RADOS)
Here we compared 4KiB RADOS object writes.
This figure contains plots from Figure 4 as well as the corresponding BlueStore results.
The scripts for running these benchmarks are in the `Cluster_Bench_Scripts/`
directory.
Scripts of the form `benchmark_micro_*` are RADOS benchmarks.
You probably want to use `benchmark_micro_write.sh`.
```bash
./benchmark_micro_write.sh 4KB
```


## Figure 9 (The throughput of variable-sized RBD object writes)
Here we measure the write throughput of RBD with Filestore compared to
BlueStore.
Throughput is evaluated at various object sizes.
Results shown are for the HDD cluster.

We use the Flexibile I/O tester (FIO) tool to perform our benchmarks.
Running the tests means we need to locally mount a block device from Ceph.

RBD creation scripts are in `RBD_Setup/`.

We can mount replicated RBD with:
```bash
cd RBD_Setup
./rbd_setup.sh
```

Erasure coding parameters (e.g., k and m) can be found in the `ec_rbd_bench.sh`
scripts.
We can mount an Erasure coded RBD with:
```bash
cd RBD_Setup
./ec_rbd_setup.sh
```

Mounting a RBD device successfully should result in something as follows:
![RBD_Mount](Figures/RBD_Mount.png)

The scripts for running these benchmarks are in the `Cluster_Bench_Scripts/`
directory (`Cluster_Bench_Scripts/ec_rbd_bench.sh` or `Cluster_Bench_Scripts/rbd_bench.sh`).
The scripts are given the rbd device as an argument.

For example, if the rbd device is name rbd0, you can do the following for a
replicated RBD test:
```bash
cd Cluster_Bench_Scripts
./rbd_bench.sh /dev/rbd0
```

Similarly, for an erasure coded device:
```bash
cd Cluster_Bench_Scripts
./ec_rbd_bench.sh /dev/rbd0
```

If you mount multiple RBD devices, you'll get higher numbered rbd devices.
In the following case, we use rbd1.
![RBD_Bench](Figures/RBD_Bench.png)



## Figure 10 (The IOPS of random 4 KiB writes to RBD with Replication and EC)
Here we measure the IOPS from 8 clients to RBD.
Results shown are for the HDD cluster.
The scripts for running these benchmarks are in the `Cluster_Bench_Scripts/`
directory, although they do require testing 8 clients in parallel rather than 1.
RBD creation scripts are in `RBD_Setup/`.

To do the parallel run setup, run the setup script to create a replicated or EC RBD.
You can continue to mount rbd devices on a node as follows:
```bash
sudo rbd map myrbd
```

Running the test is parallel can be done as it is done in the scripts from Figure 9.
However, the tests must be started in parallel.
Be careful to not clobber output files by having them map to the same location.
We mounted all 8 devices on the same node in our experiments.
