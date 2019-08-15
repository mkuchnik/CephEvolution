# Ceph_Deploy_Install_Scripts
These are ceph-deploy scripts which we have previously used to bootstrap a
cluster.
We currently use ceph-ansible, and these are provided for historical reasons.

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
It also handles adding information for where Ceph repositories are.
``deploy_ceph_all.sh`` copies ``deploy_ceph.sh`` to other nodes and runs it
there.
Finally, ``install_cluster_param.sh`` actually installs Ceph on the nodes.
