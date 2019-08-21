#!/bin/bash
# This script runs deply_ceph.sh on all nodes and copies ssh keys
# Since we don't use a special Ceph user, we probably don't need to copy keys

set -e

# params

# We assume a shared filesystem with which we can distribute other scripts
# through. You will have to change this path
#ScriptsHome="path/to/shared/ceph_deploy_scripts"
# Note: by default we assume it's current directory and pass it above
ScriptsHome=$1
# We assume a shared filesystem with which we can distribute other scripts
# through. You will have to change this path to point to deploy_ceph.sh
#script_location="path/to/scripts/deploy_ceph.sh"
# Note: by default we assume it's in current directory
script_location="${ScriptsHome}/deploy_ceph.sh"
# Name used to install Ceph. This will have to be changed to your user
# Note: by default we assume current user
CephAdminUsername=$(id -un)
# The prefix for hostnames
# We assume 16 hosts, which are named h0, h1, h2, ... h15
node_prefix="h"

if [ "$#" -eq 0 ]; then
  echo "Need scripts home argument"
  exit 1
fi

# 1. Run deploy_ceph.sh on all nodes
pdsh -w "${node_prefix}[1-15]" "bash ${script_location} ${ScriptsHome}"

# 2. Generate a keypair
# We don't need to do this usually but we could with ssh-keygen

# 3. Copy keypair to nodes
# Again we don't really need to do this since we have keypairs
#for i in {1..15}; do
#  ssh-copy-id "${CephAdminUsername}@${nodes_prefix}$i"
#done
