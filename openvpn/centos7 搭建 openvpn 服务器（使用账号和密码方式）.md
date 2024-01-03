# centos7 搭建 openvpn 服务器（使用账号和密码方式）

搭建及要实现的内容如下：
1、server端和client端的安装和配置
2、配置防火墙及路由转发
3、配置账号密码验证，给账号分配固定IP，且用户连接与断开实时调用后续处理脚本

## 一、制作证书

安装`easy-rsa`和`openvpn`软件包

```
yum install openvpn easy-rsa
```

复制相关文件

```
//注意easy-rsa的版本号，你的有可能不一样
cp /usr/share/doc/easy-rsa-3.0.7/vars.example /etc/openvpn/easy-rsa/vars
cp -r /usr/share/easy-rsa/3.0.7/* /etc/openvpn/easy-rsa/
```

编辑vars文件，修改如下选项（此步骤为可选操作，使用默认的也是可以的）

```
vi /etc/openvpn/easy-rsa/vars

#set_var EASYRSA_REQ_COUNTRY    "US"
#set_var EASYRSA_REQ_PROVINCE   "California"
#set_var EASYRSA_REQ_CITY       "San Francisco"
#set_var EASYRSA_REQ_ORG        "Copyleft Certificate Co"
#set_var EASYRSA_REQ_EMAIL      "panguanjun@chuxou.com"
#set_var EASYRSA_REQ_OU         "My Organizational Unit"

#修改公司、邮箱、国家等信息，大约250行附近
```

初始化证书目录

```
cd /etc/openvpn/easy-rsa/
./easyrsa init-pki
```

创建CA根证书

```
./easyrsa build-ca
#需输入两次密码和一次名称，或者不设置直接都回车，看不懂提示可翻译，根据自己情况定义
```

创建服务器端证书，执行命令一路回车

```
./easyrsa gen-req server nopass
#一路回车即可，看不懂提示可翻译，根据自己情况定义
```

签署服务器端证书

```
./easyrsa sign server server
# 回车后输入yes，还需输入之前创建CA根证书设置的密码，如未设置直接回车，看不懂提示可翻译，根据自己情况定义
```

生成加密交换时的Diffie-Hellman文件，会生成一个pem后缀文件，生成过程比较慢

```
./easyrsa gen-dh
```

## 2、配置openvpn服务端

```
vi /etc/openvpn/server.conf

# 以下配置可直接复制

port 1194
proto tcp
dev tun

# 相关证书配置路径
ca /etc/openvpn/easy-rsa/pki/ca.crt
cert /etc/openvpn/easy-rsa/pki/issued/server.crt
key /etc/openvpn/easy-rsa/pki/private/server.key
dh /etc/openvpn/easy-rsa/pki/dh.pem

server 10.8.0.0 255.255.255.0    # 虚拟网段

client-to-client    # 客户端互通
keepalive 10 120
comp-lzo

cipher AES-256-CBC
persist-key
persist-tun

status logs/openvpn-status.log  # 状态日志路径
log-append logs/openvpn.log     # 运行日志
verb 3                          # 调试信息级别

client-config-dir /etc/openvpn/ccd  # 固定IP分配配置目录，见下面讲解

script-security 2
auth-user-pass-verify /etc/openvpn/checkpwd.sh via-file    # 密码验证脚本
username-as-common-name
verify-client-cert none

# client-connect /etc/openvpn/scripts/connect.sh           # 新连接连接时执行脚本
# client-disconnect /etc/openvpn/scripts/disconnect.sh     # 有连接退出时执行脚本
```

创建用户账号和密码的配置

```
touch /etc/openvpn/pwd-file
vi /etc/openvpn/pwd-file

# 文件内容为
# 每一行代表一个用户，账号和密码以空格分开
client1 123456
client2 123456
client3 123456
```

给用户client1分配固定IP为10.8.0.57

```
mkdir /etc/openvpn/ccd
cd  /etc/openvpn/ccd

# 文件名称需以用户账号命名
touch /etc/openvpn/ccd/client1
vi /etc/openvpn/ccd/client1

#文件内容
ifconfig-push 10.8.0.57 10.8.0.58
```

创建密码验证脚本

```
touch /etc/openvpn/checkpwd.sh
chmod +x checkpwd.sh
vi /etc/openvpn/checkpwd.sh

# 脚本内容

#!/bin/bash

PASSFILE="/etc/openvpn/pwd-file"
LOG_FILE="/etc/openvpn/logs/openvpn-password.log"
TIME_STAMP=`date "+%Y-%m-%d %T"`

readarray -t lines < $1
username=${lines[0]}
password=${lines[1]}

if [ ! -r "${PASSFILE}" ]; then
  echo "${TIME_STAMP}: Could not open password file \"${PASSFILE}\" for reading." >> ${LOG_FILE}
  exit 1
fi

CORRECT_PASSWORD=`awk '!/^;/&&!/^#/&&$1=="'${username}'"{print $2;exit}' ${PASSFILE}`

if [ "${CORRECT_PASSWORD}" = "" ]; then
  echo "${TIME_STAMP}: User does not exist: username=\"${username}\", password=\"${password}\"." >> ${LOG_FILE}
  exit 1
fi

if [ "${password}" = "${CORRECT_PASSWORD}" ]; then
  echo "${TIME_STAMP}: Successful authentication: username=\"${username}\"." >> ${LOG_FILE}
  exit 0
fi

echo "${TIME_STAMP}: Incorrect password: username=\"${username}\", password=\"${password}\"." >> ${LOG_FILE}
exit 1
```



（可选配置）争对client-connect和client-disconnect这两个配置这里就不多说了，可能对大多数人用处不大，我的业务是有用户连接上了，就调用脚本向远程http接口通知我们系统有客户连接上了然后去做业务处理的，我把大致脚本发出来

```
connect.sh

# 脚本内容

#!/bin/bash

echo " 发现新连接 >>>>> 账号: ${common_name} 分配IP: ${trusted_ip} 连接者IP: ${ifconfig_pool_remote_ip}"
# 上报到远程接口，使用curl等工具...
exit 0
```

开启内核路由转发功能

```
echo "net.ipv4.ip_forward = 1" >>/etc/sysctl.conf
sysctl -p
```

配置防火墙

```
# 开放tcp 1194端口
firewall-cmd --zone=public --add-port=1194/tcp --permanent
# 重新加载防火墙使其生效
firewall-cmd --reload
# 查看防火墙规则是否配置成功
firewall-cmd --list-all
```

启动openvpn服务器

```
openvpn /etc/openvpn/server.conf &
或者
systemctl start openvpn@server    # 启动服务
systemctl status openvpn@server   # 查看状态
systemctl stop openvpn@server     # 停止服务
```

执行start启动服务命令后，使用status命令查询状态，如果`Active: failed`，请到`/etc/openvpn/logs/openvpn.log`目录下查看日志，基本打印的错误消息挺全的，可借此排查错误，另外记得如果开启了防火墙要把openvpn配置的端口开放，并且有的服务商还在他们自己控制台有安全策略，如果服务启动了连接很久都连接不上可以往这些方面思考一下

## 配置openvpn客户端

创建配置文件

```
cd /root/
touch client.ovpn
vi /etc/openvpn/easy-rsa/pki/ca.crt    # 复制所有内容
vi /root/client.ovpn 

# client.ovpn文件内容
client 
dev tun 
proto tcp 
remote 193.112.xxx.xxx 1194    # openvpn远程服务器的IP和端口
resolv-retry infinite 
nobind 
persist-key 
persist-tun 
cipher AES-256-CBC 
comp-lzo 
verb 3 
auth-user-pass     # 添加此配置客户端连接时会弹出密码框

# 证书配置
<ca>
#此处粘贴刚才在/etc/openvpn/easy-rsa/pki/ca.crt复制的内容
</ca>
```

然后导出`client.ovpn`文件，导入到客户端里进行连接

openvpn客户端官方下载连接
https://openvpn.net/community-downloads/

下载安装时注意如果弹出要安装`TAP-Windows Provider V9`的东西一定要通过，不然安装成功了，连接时还是无法连接

客户端
[![Alt text](https://sevennight.cc/image/1587143697591.png)](https://sevennight.cc/image/1587143697591.png)

启动客户端软件，然后在任务栏有一个像电脑显示器的小图标右键选择导入配置文件
[![Alt text](https://sevennight.cc/image/1587143802423.png)](https://sevennight.cc/image/1587143802423.png)

连接
[![Alt text](https://sevennight.cc/image/1587143950209.png)](https://sevennight.cc/image/1587143950209.png)

在弹出的密码框里输入我们在服务端`pwd-file`文件里配置的用户名和密码
[![Alt text](https://sevennight.cc/image/1587144012062.png)](https://sevennight.cc/image/1587144012062.png)

连接成功，且IP也是成功分配到我们配置的IP
[![Alt text](https://sevennight.cc/image/1587144242918.png)](https://sevennight.cc/image/1587144242918.png)