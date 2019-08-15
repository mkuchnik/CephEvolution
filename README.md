# CephEvolution
A repository for replicating the experiments found in
"File Systems Unfit as Distributed Storage Backends: Lessons from 10 years of
Ceph Evolution" (SOSP '19).
Efforts were made to best follow the Research Artifact Evaluation for SOSP 2019
described [here](https://sysartifacts.github.io/instructions.html).
The Ceph project's source code can be found [here](https://github.com/ceph) and
you can find documentation [here](https://docs.ceph.com/docs/luminous/).

## Hardware Requirements
The experiments were run on the Carnegie Mellon University [Parallel Data
Lab](https://www.pdl.cmu.edu/)
[Orca](https://orca.pdl.cmu.edu)
cluster.
16 nodes are needed to run these experiments and it's assumed that each node has
a HDD and SSD.
Nodes are connected with a Cisco Nexus 3264-Q 64-port QSFP+ 40GbE switch.

Node hardware:
```
CPU: 16-core Intel E5-2698Bv3 Xeon 2GHz
RAM: 64GiB
Drives: 400GB Intel P3600 NVMe SSD, 4TB 7200RPM Seagate ST4000NM0023 HDD
NIC: Mellanox MCX314A-BCCT 40GbE
```

## Software Requirements
We use the Ceph project to demonstrate the effect of filesystem backends.
Ceph is open source and has documentation available online.
Ceph Luminous documentation can be found [here](https://docs.ceph.com/docs/luminous/start/intro/).
The Ceph project source code is available [here](https://github.com/ceph).
For the original experiments, all nodes run Linux kernel 4.15 on Ubuntu 18.04,
and the Luminous release (v12.2.11) of Ceph.
Ubuntu 16.04 should obtain similar results for RADOS experiments.
However, Ceph RBD may require newer kernel features as described [here](https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1728739).

## Experiment Descriptions
We provide instructions on reproducing the results of the experiments in the
[EXPERIMENTS.md](EXPERIMENTS.md) file.

## Getting Started
If you haven't deployed a Ceph cluster before, we recommend following the 
ceph-deploy guide found
[here](https://docs.ceph.com/docs/luminous/rados/deployment/) to understand how
Ceph works in practice.
You will need to understand how to deploy and maintain monitors, managers, and OSDs.
You do not need to deploy a MDS for our purposes.
You can then switch to the Ansible install method once you have a better idea of
what the configurations mean.
