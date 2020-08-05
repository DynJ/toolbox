#!/bin/bash

dnf update -y
dnf install -y git zsh epel-release
dnf install -y @virt
dnf install -y cockpit cockpit-machines

systemctl start cockpit.socket
systemctl enable cockpit.socket
systemctl status cockpit.socket

firewall-cmd --add-service=cockpit --permanent
firewall-cmd --reload
