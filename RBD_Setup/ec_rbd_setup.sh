#!/bin/bash
set -e

# For installing erasure coded RBD

RBDSize="1T"
pool_size=400 # Should be 400 at least
stripe_unit="4M"
stripe_count=1
k=5
m=1
expected_objects=100

sudo umount /mnt/ceph-block-device || echo 0
sudo rbd rm rbd/myrbd* || echo 0
sudo ceph tell mon.\* injectargs '--mon_debug_no_require_bluestore_for_ec_overwrites=true'
sudo ceph tell mon.\* injectargs '--mon-allow-pool-delete=true' \
&& sudo ceph osd pool delete rbd rbd --yes-i-really-really-mean-it \
&& sudo ceph osd pool delete ecpool ecpool --yes-i-really-really-mean-it \
&& sudo ceph tell mon.\* injectargs '--mon-allow-pool-delete=false' \
|| echo 0

sudo ceph osd erasure-code-profile ls
sudo ceph osd erasure-code-profile get default

# From
# https://ceph.com/community/new-luminous-erasure-coding-rbd-cephfs/
sudo ceph osd erasure-code-profile set ec_profile_${k}_${m} k=${k} m=${m} crush-failure-do
sudo ceph osd erasure-code-profile ls

sudo ceph osd pool create rbd ${pool_size} ${pool_size} replicated_rule ${expected_objects}
sudo rbd pool init rbd
echo "Creating pool"
sudo ceph osd pool create ecpool ${pool_size} ${pool_size} erasure "ec_profile_${k}_${m}"
echo "Allow overwrites"
sudo ceph osd pool set ecpool allow_ec_overwrites true

sudo ceph osd pool application enable ecpool rbd
sudo rbd create myrbd --size ${RBDSize} --image-feature layering --stripe-unit \
  ${stripe_unit} --stripe-count ${stripe_count} --data-pool ecpool
sudo rbd map myrbd --name client.admin

sudo lsblk
echo "Success"
