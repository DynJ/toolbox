#!/bin/bash

dnf update -y
dnf install -y git zsh epel-release
dnf install -y @virt virt-install
dnf install -y cockpit cockpit-machines

systemctl start cockpit.socket
systemctl enable cockpit.socket
systemctl status cockpit.socket

systemctl enable libvirtd
systemctl start libvirtd

firewall-cmd --add-service=cockpit --permanent
firewall-cmd --reload

nmcli con add type bridge con-name br0 ifname br0
nmcli con add type ethernet slave-type bridge con-name bridge-br0 ifname eno1 master br0
nmcli con up br0
nmcli con down eno1
