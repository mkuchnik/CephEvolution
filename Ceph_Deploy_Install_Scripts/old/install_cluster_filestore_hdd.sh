mkdir ceph_cluster
cd ceph_cluster

# /dev/sda Crucial/Micron RealSSD m4/C400/P400
# /dev/sdb Hitachi Ultrastar A7K2000
# /dev/sdc Hitachi Ultrastar 7K3000
# /dev/sdd Hitachi Ultrastar 7K3000

username="mkuchnik"
release="luminous"
#release="jewel"
#release="mimic"
# node_prefix="nodes-"
node_prefix="h"
n_nodes=16
start_node_id=0
# nodes="nodes-1 nodes-2 nodes-3 nodes-4 nodes-5 nodes-6 nodes-7 nodes-8 nodes-9 nodes-10 nodes-11 nodes-12 nodes-13 nodes-14 nodes-15 nodes-16"
#nodes="h0 h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11 h12 h13 h14 h15"
nodes="h0 h1 h2"
nvme_switch=false # Make sure to set this
#nvme_switch=true # Make sure to set this
#store_type="--bluestore"
store_type="--filestore"

if $nvme_switch; then
  DATA=/dev/nvme0n1
  WAL=/dev/nvme0n1
else
  DATA=/dev/sdc
  WAL=/dev/sdb
fi

## Create monitor node
ceph-deploy --username ${username} new ${node_prefix}0
##
### Install Ceph on nodes
ceph-deploy --username ${username} install --release ${release} ${nodes}
##
### Deploy initial monitor
ceph-deploy --username ${username} --overwrite-conf mon create-initial
##
### Copy configuration files and admin key
ceph-deploy --username ${username} --overwrite-conf admin ${nodes}
##
### Add manager daemon
ceph-deploy --username ${username} mgr create ${node_prefix}0
#
# Add OSDs
for h in ${nodes}; do
    echo "Installing host: ${h}"
    ssh $h sudo wipefs -a ${DATA}
    ssh $h sudo wipefs -a ${WAL}
    ssh $h sudo ceph-volume lvm zap ${DATA} --destroy
    if [ "${release}" == "jewel" ]; then
      ceph-deploy disk zap $h:${WAL}
    else
      ssh $h sudo ceph-volume lvm zap ${WAL} --destroy
    fi
    echo "Done zapping"
    ssh $h sudo parted ${WAL} mklabel gpt
    ssh $h sudo parted ${WAL} unit GB mkpart xfs 0 30
    ssh $h sudo parted ${WAL} unit GB mkpart xfs 30 360
    echo "Done partitioning"
    #ceph-deploy --username ${username} osd create --filestore --fs-type xfs \
    #  --data ${WAL}p2 --journal ${WAL}p1 ${h}
    if [ "${release}" == "jewel" ]; then
      ceph-deploy osd create ${store_type} --fs-type xfs \
        ${h}:${WAL}p2:${WAL}p1 
    else
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
    fi
done

echo "HEALTH:"
ssh ${node_prefix}1 sudo ceph health
echo "HEALTH (detailed):"
ssh ${node_prefix}1 sudo ceph -s

echo "QUORUM:"
ceph quorum_status --format json-pretty

echo "MANAGERS:"
ssh ${node_prefix}1 sudo ceph -s
