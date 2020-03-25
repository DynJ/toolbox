CONFIG_DIR="config"
cat > /etc/init.d/aria2c << "EOF"
#! /bin/sh
# /etc/init.d/aria2c
 
### BEGIN INIT INFO
# Provides: aria2cRPC
# Required-Start: $network $local_fs $remote_fs
# Required-Stop: $network $local_fs $remote_fs
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: aria2c RPC init script.
# Description: Starts and stops aria2 RPC services.
### END INIT INFO
 
RETVAL=0
case "$1" in
 start)
 echo -n "Starting aria2c daemon: "
 umask 0000
 aria2c --conf-path=/home/pi/_CONFIG_DIR_/aria2/aria2.conf -D
 RETVAL=$?
 echo
 ;;
 stop)
 echo -n "Shutting down aria2c daemon: "
 /usr/bin/killall aria2c
 RETVAL=$?
 echo
 ;;
 restart)
 stop 
 sleep 3
 start
 ;;
 *)
 echo $"Usage: $0 {start|stop|restart}"
 RETVAL=1
esac
exit $RETVAL
EOF

chmod +x /etc/init.d/aria2c
update-rc.d aria2c defaults
