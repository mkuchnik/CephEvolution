#!/bin/bash
# Installs Ceph's ceph-deploy
# We don't use Ceph admin user and instead use normal user accounts
# http://docs.ceph.com/docs/mimic/start/quick-start-preflight/

# Fail on error
set -e

# PARAMETERS
# We can put jewel, etc.
CephStableRelease="luminous"
# Name used to install Ceph. This will have to be changed to your user
CephAdminUsername="mkuchnik"
# We assume a shared filesystem with which we can distribute other scripts
# through. You will have to change this path
ScriptsHome="path/to/shared/ceph_deploy_scripts" 

# These are proxy settings used on PDL Orca
export http_proxy="http://ops:8888/"
export https_proxy="http://ops:8888/"
export ftp_proxy="http://ops:8888/"
echo "proxy:$http_proxy"

# 1. Add release key
wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -
wget -O /tmp/release.asc https://download.ceph.com/keys/release.asc
sudo apt-key add /tmp/release.asc

# 2. Add Ceph packages to your repo. This is release dependent.
echo deb \
  https://download.ceph.com/debian-${CephStableRelease}/ $(lsb_release -sc) \
  main | sudo tee /etc/apt/sources.list.d/ceph.list

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

# Add no password (probably not needed)
echo "{username} ALL = (root) NOPASSWD:ALL" \
  | sudo tee /etc/sudoers.d/${CephAdminUsername}
sudo chmod 0440 /etc/sudoers.d/${CephAdminUsername}

# Add proxy settings
echo "http_proxy=$http_proxy" | sudo tee -a /etc/environment
echo "https_proxy=$https_proxy" | sudo tee -a /etc/environment
echo "ftp_proxy=$ftp_proxy" | sudo tee -a /etc/environment

# PDL Orca setup
sudo /share/testbed/bin/linux-fixpart all                     || exit 1
sudo /share/testbed/bin/linux-localfs -t ext4 /l0             || exit 1
sudo /share/testbed/bin/localize-resolv                       || exit 1
/share/testbed/bin/sshkey                                     || exit 1
# Enable 40 Gb ethernet
sudo  /share/testbed/bin/network -f up                        || exit 1
sudo /share/testbed/bin/network --big --eth up                || exit 1

# We can rewrite hosts file to use 40Gb ethernet
sudo python3 ${ScriptsHome}/rewrite_hosts.py