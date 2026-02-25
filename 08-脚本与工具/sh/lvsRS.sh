#!/bin/bash

VIP=192.168.132.254

case "$1" in
  start)
   echo "配置lvs Real Server开始..."
   ifconfig lo:0 $VIP broadcast $VIP netmask 255.255.255.255 up
   route add -host $VIP dev lo:0
   echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore
   echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore
   echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce
   echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce
   ;;
  stop)
   echo "正在关闭lvs Real server"
   ifconfig lo:0 down
   echo "0" >/proc/sys/net/ipv4/conf/lo/arp_ignore
   echo "0" >/proc/sys/net/ipv4/conf/all/arp_ignore
   echo "0" >/proc/sys/net/ipv4/conf/lo/arp_announce
   echo "0" >/proc/sys/net/ipv4/conf/all/arp_announce
   ;;
  *)
   echo "用法：$0 {start|stop}"
   exit 1
esac
  
