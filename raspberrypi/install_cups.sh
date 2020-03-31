#!/bin/sh
apt-get -q install cups
usermod -a -G lpadmin pi
