#!/bin/bash

VIP=192.168.132.254
RIP1=192.168.132.64
RIP2=192.168.132.68

case "$1" in
  start)
    echo "开始配置LVS Director Server"
    ifconfig eth0:0 $VIP broadcast $VIP netmask 255.255.255.255 up
    route add -host $VIP dev eth0:0
    echo "1">/proc/sys/net/ipv4/ip_forward
    ipvsadm -C
    ipvsadm -A -t $VIP:80 -s rr
    ipvsadm -a -t $VIP:80 -r $RIP1:80 -g
    ipvsadm -a -t $VIP:80 -r $RIP2:80 -g
    ipvsadm
    echo "配置成功"
    ;;
  stop)
    echo "正在关闭LVS Director Server"
    echo "0">/proc/sys/net/ipv4/ip_forward
    ipvsadm -C
    ifconfig eth0:0 down
    echo "关闭成功！"
    ;;
  *)
    echo "用法：$0 {start|stop}"
    exit 1
esac
