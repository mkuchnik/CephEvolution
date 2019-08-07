#!/bin/bash
# Performs a RADOS bench on the cluster with a sequential read workload

set -e

pool_name="scbench3"
pool_size=1024 # Can be 1024, 2048
bench_time=600 # in seconds
object_size="$1" # put bytes (1KB,1MB,etc.)
replication_factor=3
threads=128
max_objects=10000000
read_type="seq"

pdsh -w h[0-15] "sudo echo 3 | sudo tee /proc/sys/vm/drop_caches && sudo sync"
sudo ceph -s
eval \
  "sudo ceph osd pool create ${pool_name} ${pool_size} ${pool_size} replicated \
   && sudo ceph osd pool set ${pool_name} size ${replication_factor}"
cmd="sudo rados bench -p ${pool_name} ${bench_time} ${read_type} -t ${threads} --max_objects ${max_objects} --no-cleanup"
eval "${cmd}" | tee "$(pwd)/bench_results.txt"
echo "$cmd" | tee -a "$(pwd)/bench_results.txt"
