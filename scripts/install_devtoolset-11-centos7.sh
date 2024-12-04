#!/bin/bash

set -x

#Yum installation steps for devtoolset-11

sudo yum install centos-release-scl -y

sudo mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
sudo mv /etc/yum.repos.d/CentOS-SCLo-scl.repo /etc/yum.repos.d/CentOS-SCLo-scl.repo.backup
sudo mv /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo.backup

sudo tee /etc/yum.repos.d/CentOS-Vault.repo <<EOF
[base]
name=CentOS-\$releasever - Base
baseurl=http://vault.centos.org/7.9.2009/os/\$basearch/
gpgcheck=1
gpgkey=http://vault.centos.org/7.9.2009/os/\$basearch/RPM-GPG-KEY-CentOS-7

[updates]
name=CentOS-\$releasever - Updates
baseurl=http://vault.centos.org/7.9.2009/updates/\$basearch/
gpgcheck=1
gpgkey=http://vault.centos.org/7.9.2009/updates/\$basearch/RPM-GPG-KEY-CentOS-7

[extras]
name=CentOS-\$releasever - Extras
baseurl=http://vault.centos.org/7.9.2009/extras/\$basearch/
gpgcheck=1
gpgkey=http://vault.centos.org/7.9.2009/extras/\$basearch/RPM-GPG-KEY-CentOS-7

[centos-sclo-rh]
name=CentOS-7 - SCLo rh
baseurl=http://vault.centos.org/7.9.2009/sclo/\$basearch/rh/
gpgcheck=1
gpgkey=http://vault.centos.org/7.9.2009/os/\$basearch/RPM-GPG-KEY-CentOS-7

[centos-sclo-sclo]
name=CentOS-7 - SCLo sclo
baseurl=http://vault.centos.org/7.9.2009/sclo/\$basearch/sclo/
gpgcheck=1
gpgkey=http://vault.centos.org/7.9.2009/os/\$basearch/RPM-GPG-KEY-CentOS-7
EOF


sudo yum clean all
sudo yum makecache

sudo yum install devtoolset-11 --nogpgcheck -y


##scl enable devtoolset-11 bash
