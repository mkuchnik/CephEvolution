#!/bin/bash
set -e

# For installing replicated RBD

RBDSize="1T"
pool_size=400 # Should be 400 at least
stripe_unit="4M"
stripe_count=1
expected_objects=100

# We may need to clean up old rbd devices
sudo umount /mnt/ceph-block-device || echo 0
sudo rbd rm rbd/myrbd* || echo 0
sudo ceph tell mon.\* injectargs '--mon-allow-pool-delete=true' \
&& sudo ceph osd pool delete rbd rbd --yes-i-really-really-mean-it \
&& sudo ceph tell mon.\* injectargs '--mon-allow-pool-delete=false' \
|| echo 0

# We may need to create the pool
sudo ceph osd pool create rbd ${pool_size} ${pool_size} replicated_rule ${expected_objects}
sudo rbd pool init rbd

echo "Create myrbd"
sudo rbd create myrbd --size ${RBDSize} --image-feature layering --stripe-unit \
  ${stripe_unit} --stripe-count ${stripe_count}
echo "Map myrbd"
sudo rbd map myrbd --name client.admin

sudo lsblk
echo "Success"
