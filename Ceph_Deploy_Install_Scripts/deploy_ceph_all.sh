#!/bin/bash

# fail on error
# set -e

# params
script_location="/users/mkuchnik/Programming/CephExp/scripts/deploy_ceph.sh"
CephAdminUsername="mkuchnik" # TODO this has to be the same as deploy_ceph.sh
ScriptsHome="/users/mkuchnik/Programming/CephExp/scripts"
node_prefix="nodes-"
node_prefix="h"

# 1. Run deploy_ceph.sh on all nodes
pdsh -w "${node_prefix}[1-15]" "bash $script_location"

# 2. Generate a keypair
# TODO we don't need to do this usually
# ssh-keygen

# 3. Copy keypair to nodes
for i in {1..15}; do
  ssh-copy-id "${CephAdminUsername}@${nodes_prefix}$i"
done

full_script_path="${ScriptsHome}/rewrite_hosts.py"
rewrite_hosts_cmd="sudo python3 ${full_script_path}"

echo ${rewrite_hosts_cmd}

# pdsh -w ${nodes_prefix}[1-16] ${rewrite_hosts_cmd}

# sudo python3 ${ScriptsHome}/rewrite_hosts.py

# 4. TODO add nodes with CephAdmin to ~/.ssh/config
