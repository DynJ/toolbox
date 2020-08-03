#!/bin/sh

dnf install -y @virt
systemctl enable libvirtd
systemctl start libvirtd

nmcli connection show
