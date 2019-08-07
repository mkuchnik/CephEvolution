#!/bin/bash
# A convenience script for purging the Ceph cluster.
# It's usually a good idea to restart the cluster after doing this.

set -e

HOSTFILE="hosts16.yml"

source ceph-ansible/venv/bin/activate
cd ceph-ansible
ansible-playbook -i ${HOSTFILE} infrastructure-playbooks/purge-cluster.yml