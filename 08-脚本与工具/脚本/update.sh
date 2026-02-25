#!/bin/bash
# ----------------------------------
# Version: v1.0
# Date: 2021/05/19
# Author: 
# Email: 
# Description: System initialization
# System version：Centos7 x86_64
# ----------------------------------
clear
if [ $(whoami) != 'root' ];then
	echo "Please Run as root"
	exit 1
fi
if [ $(uname -i) != "x86_64" ];then
	echo "System is wrong"
	exit 2
fi
cat << EOF
******************************************************
*               System initialization                *
******************************************************
EOF
read -s -n1 -p "--Press any key to continue，or press（Ctrl+C）cancel--"
ping -c 2 223.5.5.5 > /dev/null 2>&1
if [ $? != 0 ];then
    echo "The network is down"
	exit 3
fi
yum_config(){
	yum install -y wget curl
	mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
	curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
	yum clean all && yum makecache
	yum install -y epel-release
	yum update -y
}
yum_tools(){
	yum install -y lrzsz unzip gcc gcc-c++ vim tree man tmux
	yum install -y gcc gcc-c++ make cmake autoconf openssl-devel openssl-perl net-tools
}
firewalld_config(){
	sed -i  's/^SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
	setenforce 0
	systemctl start firewalld && systemctl enable firewalld
	firewall-cmd --zone=public --add-port=80/tcp
	firewall-cmd --runtime-to-permanent
	firewall-cmd --reload
}
history_config(){
	cat >> /etc/profile << "EOF"
	export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S"
	export HISTSIZE=100000
	export HISTFILESIZE=1000000
	export HISTFILE=~/.bash_history
	shopt -s histappend
	PROMPT_COMMAND='history -a'
	shopt -s histappend
EOF
}
main(){
	yum_config
	yum_tools
#	firewalld_config
	history_config
}
main
#NAME=`ifconfig | grep broadcast | awk '{print$2}'`
#hostnamectl --static set-hostname $NAME
source /etc/profile
source /etc/profile
source /etc/profile
clear
cat << EOF
******************************************************
*            Initialization completed !              *
******************************************************
******************************************************
*            Please restart the server               *
******************************************************
EOF