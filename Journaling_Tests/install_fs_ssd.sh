#!/bin/bash

WAL=/dev/nvme0n1
FS=${1}

sudo umount ${WAL}
sudo umount ${WAL}p1
sudo umount ${WAL}p2
sudo umount ${WAL}p3

sudo parted ${WAL} mklabel gpt
sudo parted ${WAL} unit GB mkpart ${FS} 0 30
sudo parted ${WAL} unit GB mkpart ${FS} 30 60
sudo parted ${WAL} unit GB mkpart ${FS} 60 120

sleep 3

sudo mkdir /media/dbhdd
sudo wipefs -af ${WAL}p1
sudo mkfs.${FS} ${WAL}p1
sudo mount -t auto -v ${WAL}p1 /media/dbhdd
sudo chown -R $(whoami) /media/dbhdd

sudo wipefs -af ${WAL}p2
sudo chown -R $(whoami) ${WAL}p2

sudo mkdir /media/filehdd
sudo wipefs -af ${WAL}p3
sudo mkfs.${FS} ${WAL}p3
sudo mount -t auto -v ${WAL}p3 /media/filehdd
sudo chown -R $(whoami) /media/filehdd
