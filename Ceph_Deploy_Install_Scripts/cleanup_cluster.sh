#!/bin/bash
# Erases all Ceph data and configuration
# http://docs.ceph.com/docs/master/start/quick-ceph-deploy/

username="mkuchnik"
# TODO put nodes here
nodes="h0 h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11 h12 h13 h14 h15"

pdsh -w h[0-15] "sudo ceph osd purge osd.0 --yes-i-really-mean-it"

cd ceph_cluster
ceph-deploy --username $username purge $nodes
ceph-deploy --username $username purgedata $nodes
ceph-deploy --username $username forgetkeys
rm ceph.*
cd ..
rm -rf ceph_cluster/
