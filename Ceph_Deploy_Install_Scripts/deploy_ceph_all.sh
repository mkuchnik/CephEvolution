#!/bin/bash
# This script runs deply_ceph.sh on all nodes and copies ssh keys
# Since we don't use a special Ceph user, we probably don't need to copy keys

set -e

# params
# We assume a shared filesystem with which we can distribute other scripts
# through. You will have to change this path to point to deploy_ceph.sh
script_location="path/to/scripts/deploy_ceph.sh"
# Name used to install Ceph. This will have to be changed to your user
CephAdminUsername="mkuchnik"
node_prefix="h"

# 1. Run deploy_ceph.sh on all nodes
pdsh -w "${node_prefix}[1-15]" "bash $script_location"

# 2. Generate a keypair
# We don't need to do this usually but we could with ssh-keygen

# 3. Copy keypair to nodes
for i in {1..15}; do
  ssh-copy-id "${CephAdminUsername}@${nodes_prefix}$i"
done
