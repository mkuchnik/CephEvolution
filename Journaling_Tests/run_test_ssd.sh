#!/bin/bash

DBPath="/media/dbhdd"
FilestorePath="/media/filehdd/"
BlockPath="/dev/nvme0n1p2"
FS="xfs"
NObjects=50000
TAG=""

FullDBPath="${DBPath}/testdb"
mkdir FullDBPath

bash install_fs_ssd.sh ${FS}
sudo sync && sudo /sbin/sysctl vm.drop_caches=3 && sudo sync
time ./main ${NObjects} filesystem ${FullDBPath} ${FilestorePath} | tee \
  filestore_test_ssd_${FS}_${NObjects}${TAG}.txt;

bash install_fs_ssd.sh ${FS}
sudo sync && sudo /sbin/sysctl vm.drop_caches=3 && sudo sync
time ./main ${NObjects} raw_block ${FullDBPath} ${BlockPath} | tee \
  bluestore_test_ssd_${FS}_${NObjects}${TAG}.txt;
