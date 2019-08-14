#!/bin/bash
# Performs a RADOS bench on the cluster with a write workload

set -e

pool_name="scbench3"
pool_size=1024 # Can be 1024, 2048
bench_time=1200 # in seconds
object_size="$1" # put bytes (1KB,1MB,etc.)
replication_factor=3
threads=128
#max_objects=1000000000000
max_objects=-1 # Unlimited

eval \
  "sudo ceph tell mon.\* injectargs '--mon-allow-pool-delete=true' \
   && sudo ceph osd pool delete rbd rbd --yes-i-really-really-mean-it \
   && sudo ceph osd pool delete ${pool_name} ${pool_name} --yes-i-really-really-mean-it \
   && sudo ceph tell mon.\* injectargs '--mon-allow-pool-delete=false'" \
  || time echo 0

pdsh -w h[0-15] "sudo sync && sudo /sbin/sysctl vm.drop_caches=3 && sudo sync"
sudo ceph -s

# Give some time for things to settle down
sleep 1m

sudo ceph -s

eval \
  "sudo ceph osd pool create ${pool_name} ${pool_size} ${pool_size} replicated \
   && sudo ceph osd pool set ${pool_name} size ${replication_factor}"
if [[ $max_objects -lt 0 ]]; then
  # no object limit
cmd="sudo rados bench -p ${pool_name} ${bench_time} write -b ${object_size} -t ${threads} --no-cleanup"
else
cmd="sudo rados bench -p ${pool_name} ${bench_time} write -b ${object_size} -t ${threads} --max_objects ${max_objects} --no-cleanup"
fi
eval "${cmd}" | tee "$(pwd)/bench_results.txt"
echo "$cmd" | tee -a "$(pwd)/bench_results.txt"
