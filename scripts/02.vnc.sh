#!/bin/sh

#
# ref: https://www.linuxtechi.com/install-configure-vnc-server-centos8-rhel8/
#

# Step 2) Install VNC Server (tigervnc-server)
dnf install -y tigervnc-server

# Step 3) Set VNC Password for Local User
echo "vncpassword"
#vncpasswd

# Step 4) Setup VNC Server Configuration File
sed -i -e 's/<USER>/djia/' /lib/systemd/system/vncserver@.service

# Step 5) Start VNC Service and allow port in firewall
systemctl daemon-reload
systemctl start vncserver@:1.service
systemctl enable vncserver@:1.service

netstat -tunlp | grep 5901
systemctl status vncserver@:1.service

firewall-cmd --permanent --add-port=5901/tcp
firewall-cmd --reload

