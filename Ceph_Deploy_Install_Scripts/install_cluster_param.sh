mkdir ceph_cluster
cd ceph_cluster

# /dev/sda Crucial/Micron RealSSD m4/C400/P400
# /dev/sdb Hitachi Ultrastar A7K2000
# /dev/sdc Hitachi Ultrastar 7K3000
# /dev/sdd Hitachi Ultrastar 7K3000

username="mkuchnik"
release="luminous" # Jewel is not supported"
node_prefix="h"
n_nodes=16
#n_nodes=1
start_node_id=0
#nvme_switch=false # Make sure to set this
nvme_switch=$2 # Make sure to set this
#store_type="--bluestore"
store_type=$1

# TODO can compute with above
nodes="h0 h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11 h12 h13 h14 h15"
#nodes="h0 h1 h2 h3"

if $nvme_switch; then
  DATA=/dev/nvme0n1
  WAL=/dev/nvme0n1
  END_PART=350
else
  DATA=/dev/sdc
  WAL=/dev/sdb
  END_PART=2500
fi

# Create monitor node
ceph-deploy --username ${username} new ${node_prefix}0

# Install Ceph on nodes
ceph-deploy --username ${username} install --release ${release} ${nodes}

# Deploy initial monitor
ceph-deploy --username ${username} --overwrite-conf mon create-initial

# Copy configuration files and admin key
ceph-deploy --username ${username} --overwrite-conf admin ${nodes}

# Add manager daemon
ceph-deploy --username ${username} mgr create ${node_prefix}0

nodes_range="${node_prefix}[${start_node_id}-$((n_nodes-1))]"
echo "Nodes range is ${nodes_range}"

#pdsh -w ${nodes_range} "sudo wipefs -a ${DATA}"
pdsh -w ${nodes_range} "sudo wipefs -af ${WAL}"
#pdsh -w ${nodes_range} "sudo ceph-volume lvm zap ${DATA} --destroy"
pdsh -w ${nodes_range} "sudo ceph-volume lvm zap ${WAL} --destroy"
pdsh -w ${nodes_range} "sudo parted ${WAL} mklabel gpt"
pdsh -w ${nodes_range} "sudo parted ${WAL} unit GB mkpart xfs 0 100"
pdsh -w ${nodes_range} "sudo parted ${WAL} unit GB mkpart xfs 100 ${END_PART}"

# Add OSDs
for nid in $(seq ${start_node_id} 1 $((n_nodes-1))); do
    h="${node_prefix}${nid}"
    # for NVMe
    if $nvme_switch; then
      ceph-deploy --username ${username} osd create ${store_type} --fs-type xfs \
        --data ${WAL}p2 --journal ${WAL}p1 ${h}
    else
    # for HDD
      ceph-deploy --username ${username} osd create ${store_type} --fs-type xfs \
        --data ${WAL}2 --journal ${WAL}1 ${h}
      # If splitting data/journal by device, use something like:
      # --data ${DATA} --journal ${WAL}1 ${h}
    fi
done

echo "HEALTH:"
ssh ${node_prefix}1 sudo ceph health
echo "HEALTH (detailed):"
ssh ${node_prefix}1 sudo ceph -s

# Metadata server (Filesystem)
ceph-deploy --username ${username} mds create ${node_prefix}1

# More monitors
# TODO add or create?
ceph-deploy --username ${username} mon add ${node_prefix}1 ${node_prefix}2
ceph-deploy --username ${username} mon create ${node_prefix}1 ${node_prefix}2
echo "QUORUM:"
ceph quorum_status --format json-pretty

# More Managers
ceph-deploy --username ${username} mgr create ${node_prefix}1
ceph-deploy --username ${username} mgr create ${node_prefix}2
echo "MANAGERS:"
ssh ${node_prefix}1 sudo ceph -s

# Object Gateways
ceph-deploy --username ${username} rgw create ${node_prefix}1

ceph_cluster_dir=$(pwd)
for nid in $(seq ${start_node_id} 1 $((n_nodes-1))); do
  h="${node_prefix}${nid}"
  ssh ${h} "cd ${ceph_cluster_dir}; sudo systemctl restart ceph-mgr@${h}.service; sudo systemctl restart ceph-mon@${h}.service"
done

ssh ${node_prefix}1 sudo ceph -s
