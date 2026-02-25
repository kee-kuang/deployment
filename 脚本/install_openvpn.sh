#!/bin/bash

# Pritunl + MongoDB 自动化安装脚本 (Rocky Linux 8)
# 系统要求: Rocky Linux / AlmaLinux / RHEL 8

set -e

echo "--- 正在更新系统并安装基础依赖 ---"
sudo dnf -y update
sudo dnf -y install epel-release curl tar procps-ng

echo "--- 配置 MongoDB 8.0 软件源 ---"
sudo tee /etc/yum.repos.d/mongodb-org-8.0.repo << EOF
[mongodb-org-8.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/8/mongodb-org/8.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://pgp.mongodb.com/server-8.0.asc
EOF

echo "--- 配置 Pritunl 软件源 ---"
sudo tee /etc/yum.repos.d/pritunl.repo << EOF
[pritunl]
name=Pritunl Repository
baseurl=https://repo.pritunl.com/stable/yum/oraclelinux/8/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://raw.githubusercontent.com/pritunl/pgp/master/pritunl_repo_pub.asc
EOF

echo "--- 开始安装 MongoDB 和 Pritunl ---"
# 使用 --allowerasing 确保解决与旧版 openvpn 的冲突
sudo dnf -y install mongodb-org pritunl
sudo dnf -y --allowerasing install pritunl-openvpn

echo "--- 启动服务并设置开机自启 ---"
sudo systemctl daemon-reload
sudo systemctl enable mongod pritunl
sudo systemctl start mongod pritunl

echo "------------------------------------------------"
echo "安装完成！"
echo "1. 请访问: https://$(curl -s ifconfig.me)"
echo "2. 初始化 Setup Key:"
sudo pritunl setup-key
echo "3. 默认管理员账号和密码:"
sudo pritunl default-password
echo "------------------------------------------------"