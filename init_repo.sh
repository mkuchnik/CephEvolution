#!/bin/bash
# Installs dependencies and boots a cluster so that tests can be run.
# This is to reproduce the results found in the paper, and other clusters will
# require modifications in the configuration (e.g., different drive configs).

set -e

# We need a hostfile describing the cluster config
HOSTFILE="hosts16.yml"
# We also can use SSD or HDD for our disk backend.
USESSD=false


# Dependency usage:
# virtualenv: install ansible via pip
# fio: for RBD benchmarks

sudo apt-get update
sudo apt-get install virtualenv fio
virtualenv -p python3 ceph-ansible/venv
source ceph-ansible/venv/bin/activate
# We need ansible
pip3 install -r ceph-ansible/requirements.txt
cd ceph-ansible
# We perform drive partitioning for OSDs via LVM
if ${USESSD};
then
  echo "Using NVME"
  ansible-playbook -i ${HOSTFILE} partition_cluster_lvm.yml \
    --extra-vars "OSDDrive=nvme0n1"
else
  echo "Using SDB"
  ansible-playbook -i ${HOSTFILE} partition_cluster_lvm.yml \
    --extra-vars "OSDDrive=sdb"
fi
# We install Ceph
ansible-playbook -i ${HOSTFILE} site.yml