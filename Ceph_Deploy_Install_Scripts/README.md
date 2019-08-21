# Ceph_Deploy_Install_Scripts
These are ceph-deploy scripts which we have previously used to bootstrap a
cluster.
We currently use ceph-ansible, and these are provided for historical reasons.
These scripts are not portable across clusters, and are heavily tuned to the
cluster we used.
However, if you do want to use them, read and understand the documentation here
so that you know what each part of the script does:
[here](https://docs.ceph.com/docs/luminous/rados/deployment/).

The scripts you use to launch the cluster are:
For Bluestore HDD:
```bash
bash run_full_install_bluestore_hdd.sh
```
For Filestore HDD:
```bash
bash run_full_install_filestore_hdd.sh
```
For Bluestore NVMe (SSD):
```bash
bash run_full_install_bluestore_nvme.sh
```
For Filestore NVMe (SSD):
```bash
bash run_full_install_filestore_nvme.sh
```

If you open one of these, you will see that it calls ``setup_ceph_deploy.sh``,
``deploy_ceph.sh``, ``deploy_ceph_all.sh``, and ``install_cluster_param.sh``.
``setup_ceph_deploy.sh`` simply sets the communication default for `/etc/pdsh/rcmd_default`.
``deploy_ceph.sh`` sets proxies and other PDL Orca specific configurations;
without this, naming nodes may not work.
These PDL Orca scripts are not applicable to other clusters; you can ignore
them.
It also handles adding information for where Ceph repositories are.
``deploy_ceph_all.sh`` copies ``deploy_ceph.sh`` to other nodes and runs it
there.
Finally, ``install_cluster_param.sh`` actually installs Ceph on the nodes.

For porting to a different cluster, you'll want to change devices in ``install_cluster_param.sh``.
We also make an assumption on having a common view of scripts between nodes
(e.g., a network filesystem).
If you don't have such a setup, you will have to emulate the view by copying the
scripts in this directory onto the same path on each node.
The easiest way to do this would be to simply clone the repo in the same
directory.
