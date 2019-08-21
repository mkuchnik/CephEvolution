#!/bin/bash
# Installs Bluestore with NVMe
set -e

sudo bash setup_ceph_deploy.sh
bash deploy_ceph.sh $(pwd)
bash deploy_ceph_all.sh $(pwd)
bash install_cluster_param.sh "--bluestore" "true"