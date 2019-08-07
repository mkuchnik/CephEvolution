#!/bin/bash

DBPath="/media/dbhdd"
FilestorePath="/media/filehdd/"
BlockPath="/dev/sdb2"
FS="xfs" # We use the XFS filesystem for filesystem benchmarks
NObjects=50000 # This affects the length of time for the test
TAG=""

FullDBPath="${DBPath}/testdb"
mkdir FullDBPath

bash install_fs_hdd.sh ${FS}
sudo echo 3 | sudo tee /proc/sys/vm/drop_caches && sudo sync
time ./main ${NObjects} filesystem ${FullDBPath} ${FilestorePath} | tee \
  filestore_test_hdd_${FS}_${NObjects}${TAG}.txt;

bash install_fs_hdd.sh ${FS}
sudo echo 3 | sudo tee /proc/sys/vm/drop_caches && sudo sync
time ./main ${NObjects} raw_block ${FullDBPath} ${BlockPath} | tee \
  bluestore_test_hdd_${FS}_${NObjects}${TAG}.txt;
