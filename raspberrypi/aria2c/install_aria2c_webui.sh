#!/bin/sh

# ref: https://gist.github.com/akaxxi/15f421d00f17447b94f90fbd5d44bf72

DOWNLOAD_DIR="${HOME}/MiniDLNA"
CONFIG_DIR="${HOME}/config/aria2"
RPC_TOKEN="28GDoy-("
RPC_PORT="6800"

change_apt_source(){
        if [ -f /etc/apt/sources.list ]; then
                sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
        fi
        sudo sed -i '/^deb.*/s/^/# /g' /etc/apt/sources.list
        sudo chmod 666 /etc/apt/sources.list
        sudo echo "deb http://mirrors.tuna.tsinghua.edu.cn/raspbian/raspbian/ jessie main non-free contrib" >> /etc/apt/sources.list
        sudo echo "deb-src http://mirrors.tuna.tsinghua.edu.cn/raspbian/raspbian/ jessie main non-free contrib" >> /etc/apt/sources.list
        sudo chmod 644 /etc/apt/sources.list
}
# change_apt_source

#sudo apt-get update
#sudo apt-get install -y -q aria2 ca-certificates

if [ ! -d ${DOWNLOAD_DIR} ]; then
    mkdir -p ${DOWNLOAD_DIR}
fi

if [ ! -d ${CONFIG_DIR} ]; then
    mkdir -p ${CONFIG_DIR}
fi

if [ ! -f ${CONFIG_DIR}/aria2.session ]; then
        touch ${CONFIG_DIR}/aria2.session
fi
if [ ! -f ${CONFIG_DIR}/aria2.log ]; then
        touch ${CONFIG_DIR}/aria2.log
fi

if [ -f ${CONFIG_DIR}/aria2.conf ];then
        mv ${CONFIG_DIR}/aria2.conf ${CONFIG_DIR}/aria2.conf.bak
fi

# Generate cfg file
cat > ${CONFIG_DIR}/aria2.conf <<-EOCFG
## `#`开头为注释内容, 选项都有相应的注释说明, 根据需要修改 ##
## 被注释的选项填写的是默认值, 建议在需要修改时再取消注释  ##
## 如果出现`Initializing EpollEventPoll failed.`之类的
## 错误提示, 可以取消event-poll选项的注释                  ##

## 文件保存相关 ##

# 文件的保存路径(可使用绝对路径或相对路径), 默认: 当前启动位置
dir=${DOWNLOAD_DIR}
# 启用磁盘缓存, 0为禁用缓存, 需1.16以上版本, 默认:16M
disk-cache=32M
# 文件预分配方式, 能有效降低磁盘碎片, 默认:prealloc
# 预分配所需时间: none < falloc ? trunc < prealloc
# falloc和trunc则需要文件系统和内核支持, NTFS建议使用falloc, EXT3/4建议trunc
file-allocation=trunc
# 断点续传
continue=true
log=${CONFIG_DIR}/aria2.log
console-log-level=warn
log-level=notice

## 下载连接相关 ##

# 最大同时下载任务数, 运行时可修改, 默认:5
max-concurrent-downloads=5
# 同一服务器连接数, 添加时可指定, 默认:1
max-connection-per-server=5
# 最小文件分片大小, 添加时可指定, 取值范围1M -1024M, 默认:20M
# 假定size=10M, 文件为20MiB 则使用两个来源下载; 文件为15MiB 则使用一个来源下载
min-split-size=10M
# 单个任务最大线程数, 添加时可指定, 默认:5
split=5
# 整体下载速度限制, 运行时可修改, 默认:0
#max-overall-download-limit=0
# 单个任务下载速度限制, 默认:0
#max-download-limit=0
# 整体上传速度限制, 运行时可修改, 默认:0
#max-overall-upload-limit=0
# 单个任务上传速度限制, 默认:0
#max-upload-limit=0
# 禁用IPv6, 默认:false
disable-ipv6=true

## 进度保存相关 ##

# 从会话文件中读取下载任务
input-file=${CONFIG_DIR}/aria2.session
# 在Aria2退出时保存`错误/未完成`的下载任务到会话文件
save-session=${CONFIG_DIR}/aria2.session
# 定时保存会话, 0为退出时才保存, 需1.16.1以上版本, 默认:0
save-session-interval=60

## RPC相关设置 ##

# 启用RPC, 默认:false
enable-rpc=true
# 允许所有来源, 默认:false
rpc-allow-origin-all=true
# 允许非外部访问, 默认:false
rpc-listen-all=true
# 事件轮询方式, 取值:[epoll, kqueue, port, poll, select], 不同系统默认值不同
event-poll=epoll
# RPC监听端口, 端口被占用时可以修改, 默认:6800
rpc-listen-port=${RPC_PORT}
# RPC token
rpc-secret=${RPC_TOKEN}

## BT/PT下载相关 ##

# 当下载的是一个种子(以.torrent结尾)时, 自动开始BT任务, 默认:true
#follow-torrent=true
# BT监听端口, 当端口被屏蔽时使用, 默认:6881-6999
listen-port=51413
# 单个种子最大连接数, 默认:55
#bt-max-peers=55
# 打开DHT功能, PT需要禁用, 默认:true
enable-dht=false
# 打开IPv6 DHT功能, PT需要禁用
enable-dht6=false
# DHT网络监听端口, 默认:6881-6999
#dht-listen-port=6881-6999
# 本地节点查找, PT需要禁用, 默认:false
#bt-enable-lpd=false
# 种子交换, PT需要禁用, 默认:true
enable-peer-exchange=false
# 每个种子限速, 对少种的PT很有用, 默认:50K
#bt-request-peer-speed-limit=50K
# 客户端伪装, PT需要
peer-id-prefix=-TR2770-
user-agent=Transmission/2.77
# 当种子的分享率达到这个数时, 自动停止做种, 0为一直做种, 默认:1.0
seed-ratio=0.1
seed-time=0
# 强制保存会话, 话即使任务已经完成, 默认:false
# 较新的版本开启后会在任务完成后依然保留.aria2文件
#force-save=false
# BT校验相关, 默认:true
#bt-hash-check-seed=true
# 继续之前的BT任务时, 无需再次校验, 默认:false
bt-seed-unverified=true
# 保存磁力链接元数据为种子文件(.torrent文件), 默认:false
bt-save-metadata=true
EOCFG


# MiniDLNA
sudo apt-get install -y -q minidlna
sudo cp /etc/minidlna.conf /etc/minidlna.conf.origin
sudo sed -i 's#^media_dir=/.*#media_dir='${DOWNLOAD_DIR}'#g' /etc/minidlna.conf
sudo sed -i '/#inotify=yes/s/#//g' minidlna.conf #Enable media auto discover
sudo sed -i '$a fs.inotify.max_user_watches=65536' /etc/sysctl.conf


# aria2-webui on lighttpd
sudo apt-get install -y -q lighttpd unzip
wget https://github.com/ziahamza/webui-aria2/archive/master.zip
unzip -qu master.zip
cd webui-aria2-master/
change_token(){
        sed -i '/token:/s/\/\///g' configuration.js
        sed -i 's/\$YOUR_SECRET_TOKEN\$/'${RPC_TOKEN}'/g' configuration.js
}

# change_token

sudo cp -Rfu . /var/www/html/
cd ..
rm -rf webui-aria2-master master.zip

echo "Done!"
echo "Your Aria2 configuration and log file are in : ${CONFIG_DIR}"
echo "Your RPC token is: ${RPC_TOKEN}"
echo "Start aria2 with 'aria2c -D' and enjoy!"
echo "WebUI url: ip_raspberrypi/docs"

# install aria2 as service
cat > /etc/init.d/aria2c << "EOF"
#!/bin/sh
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

sed -i "s/_CONFIG_DIR_/${CONFIG_DIR}/' /etc/init.d/aria2c
chmod +x /etc/init.d/aria2c
service aria2c restart
update-rc.d aria2c defaults
