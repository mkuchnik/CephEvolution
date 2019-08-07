#!/bin/bash

WAL=/dev/sdb
FS=${1}

sudo umount ${WAL}
sudo umount ${WAL}1
sudo umount ${WAL}2
sudo umount ${WAL}3

sudo parted ${WAL} mklabel gpt
sudo parted ${WAL} unit GB mkpart ${FS} 0 30
sudo parted ${WAL} unit GB mkpart ${FS} 30 60
sudo parted ${WAL} unit GB mkpart ${FS} 60 120

sleep 3

sudo mkdir /media/dbhdd
sudo wipefs -a ${WAL}1
sudo mkfs.${FS} ${WAL}1
sudo mount -t auto -v ${WAL}1 /media/dbhdd
sudo chown -R $(whoami) /media/dbhdd

sudo wipefs -a ${WAL}2
sudo chown -R $(whoami) ${WAL}2

sudo mkdir /media/filehdd
sudo wipefs -a ${WAL}3
sudo mkfs.${FS} ${WAL}3
sudo mount -t auto -v ${WAL}3 /media/filehdd
sudo chown -R $(whoami) /media/filehdd
