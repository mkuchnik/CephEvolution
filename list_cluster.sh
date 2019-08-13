#!/bin/bash
# A convenience script for listing relevant cluster data
# Currently lists cluster state, OSD version, and OSD backend
# lsblk is also useful for seeing disk usage

echo "Cluster state"
ceph -s

echo "OSD version"
ceph tell osd.* version

echo "OSD backend"
ceph osd metadata $ID | grep -e id -e hostname -e osd_objectstore
