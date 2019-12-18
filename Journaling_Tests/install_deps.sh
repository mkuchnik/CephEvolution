#!/bin/bash
set -e

sudo apt-get update
sudo apt-get install libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev \
  liblz4-dev libzstd-dev git xfsprogs
# We can clone rocksdb as follows
# git clone https://github.com/facebook/rocksdb.git
# cd rocksdb
# git checkout v6.1.2
