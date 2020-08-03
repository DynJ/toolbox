#!/bin/bash

dnf --enablerepo=epel group install -y "Xfce" "base-x"

systemctl get-default
ls -l /etc/systemd/system/default.target
systemctl set-default graphical.target
systemctl get-default
ls -l /etc/systemd/system/default.target
