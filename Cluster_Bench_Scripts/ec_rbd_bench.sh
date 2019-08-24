#!/bin/bash
# Runs the RBD tests on a erasure coded RBD device

filename="${1}"
iodepth=256
size="30G"
mkdir ec_rbd-tests
for rw in "write" "randwrite" "read" "randread"; do
#for i in 4096 2048 1024 512 256 128 64 32 16 8 4; do
for i in 4096 2048 1024 512 256 128; do
  bs="${i}K"
  echo "bs ${bs}"
  cmd="sudo fio --ioengine=libaio --direct=1 --bs=${bs} --iodepth=${iodepth} \
    --end_fsync=0 \
    --rw=${rw} --norandommap --size=${size} --numjobs=1 \
    --ramp_time=None --name=rbd_test \
    --filename=${filename}"
  eval ${cmd} | tee ec_rbd-tests/${rw}-${iodepth}-${bs}.txt
  pdsh -w h[0-15] "sudo sync && sudo /sbin/sysctl vm.drop_caches=3 && sudo sync"
  sleep 1s
  pdsh -w h[0-15] "sudo systemctl restart ceph-osd.target"
  sleep 15s
done
done