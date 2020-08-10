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
# ideas: 1. config static ip?

# ref: 
# https://www.cyberciti.biz/faq/centos-8-add-network-bridge-br0-with-nmcli-command/
# https://www.linuxtechi.com/install-kvm-hypervisor-on-centos-7-and-rhel-7/
# https://www.tecmint.com/create-network-bridge-in-rhel-centos-8/
# https://www.tecmint.com/install-kvm-in-centos-8/
# https://computingforgeeks.com/how-to-create-and-configure-bridge-networking-for-kvm-in-linux/
# https://computingforgeeks.com/how-to-create-a-linux-network-bridge-on-rhel-centos-8/
# https://computingforgeeks.com/how-to-install-kvm-on-rhel-8/
# https://www.golinuxcloud.com/how-to-configure-network-bridge-nmtui-linux/

# how to install docker? --nobest

# virtio for win: 
# https://www.hiczp.com/linux/wei-kvm-zhong-de-windows-xu-ni-ji-qi-yong-virtio.html
# https://getlabsdone.com/10-easy-steps-to-install-windows-10-on-linux-kvm/#Install-Windows-virtio-drivers
