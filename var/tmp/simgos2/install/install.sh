#!/bin/sh

rhel=`cat /etc/redhat-release | cut -d \  -f 1`

if [ "$rhel" == "CentOS" ]; then
    sudo chmod +x install-centos.sh
    sudo ./install-centos.sh
fi

if [ "$rhel" == "AlmaLinux" ]; then
    sudo chmod +x install-almalinux.sh
    sudo ./install-almalinux.sh
fi

if [ "$rhel" == "Rocky" ]; then
    sudo chmod +x install-rockylinux.sh
    sudo ./install-rockylinux.sh
fi