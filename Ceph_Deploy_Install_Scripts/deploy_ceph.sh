#!/bin/bash
# Installs Ceph's ceph-deploy
# http://docs.ceph.com/docs/mimic/start/quick-start-preflight/

# Fail on error
set -e

# PARAMETERS
# This release can be changed
CephStableRelease="luminous"
#CephStableRelease="jewel"
CephAdminUsername="mkuchnik"
ScriptsHome="/users/mkuchnik/Programming/CephExp/scripts"
export http_proxy="http://ops:8888/"
export https_proxy="http://ops:8888/"
export ftp_proxy="http://ops:8888/"
echo "proxy:$http_proxy"

# 1. Add release key
wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -

# 2. Add Ceph packages to your repo. This is release dependent.
echo deb https://download.ceph.com/debian-${CephStableRelease}/ $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/ceph.list

# 3. Update and Install
# We also install ntp and ssh as that's implicitly needed
# blktrace is for benchmarking
# python3 is for script (below)
sudo apt update
sudo apt update --fix-missing
sudo apt install -y ceph-deploy \
  ntp \
  blktrace \
  python3
#  openssh-server \

# Add Ceph admin user
# This is required for passwordless SSH
#mkdir -p ${CephAdminHomeDir}
#sudo userdel ${CephAdminUsername} || echo "User doesn't exist!"
#sudo useradd -d ${CephAdminHomeDir}${CephAdminUsername} -m ${CephAdminUsername} || echo "Users Exists!"

echo "{username} ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/${CephAdminUsername}
sudo chmod 0440 /etc/sudoers.d/${CephAdminUsername}

# delete password
#sudo passwd -d ${CephAdminUsername}
#echo "{username} ALL = (ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/${CephAdminUsername}

echo "http_proxy=$http_proxy" | sudo tee -a /etc/environment
echo "https_proxy=$https_proxy" | sudo tee -a /etc/environment
echo "ftp_proxy=$ftp_proxy" | sudo tee -a /etc/environment
sudo /share/testbed/bin/linux-fixpart all                     || exit 1
sudo /share/testbed/bin/linux-localfs -t ext4 /l0             || exit 1

sudo /share/testbed/bin/localize-resolv                       || exit 1

# generate key: ssh-keygen -t rsa -f ./id_rsa
/share/testbed/bin/sshkey                                     || exit 1
# Enable 40 GB ethernet
sudo  /share/testbed/bin/network -f up                        || exit 1
sudo /share/testbed/bin/network --big --eth up                || exit 1

wget wget -O /tmp/release.asc https://download.ceph.com/keys/release.asc
sudo apt-key add /tmp/release.asc
sudo python3 ${ScriptsHome}/rewrite_hosts.py
# Fix hostnames to point to 40 GB interface
# echo -e "127.0.0.1  localhost loghost\n10.53.1.5  h2\n10.53.1.8  h3\n10.53.1.6  h0\n10.53.1.4  h1\n" | sudo tee /etc/hosts