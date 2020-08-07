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

# current issue
# virtual os can't get ip, 
# I once use VNC and virt-manager, the win10 can be remoonce use VNC and virt-manager, the win10 can be remoted.
# but when I use cocopit to create kvm, the omv can't ping google and it has no once use VNC and virt-manager, the win10 can be remoted.
# virsh net-list can't show anything. ref: https://www.cyberciti.biz/faq/find-ip-address-of-linux-kvm-guest-virtual-machine/
# not sure if virsh should show something. I didn't try it when use win10 kvm
