### 1. 安装mongodb

```
1. 安装mongodb
vim /etc/yum.repos.d/mongodb.repo
[mongodb-org-7.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/7/mongodb-org/7.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://pgp.mongodb.com/server-7.0.asc

yum install -y mongodb-org
systemctl start mongod
2. 增加用户
use admin

db.createUser(
  {
    user: "root",
    pwd: "123456",
    roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
  }
)
```

### 2. 安装nodejs

```
wget https://nodejs.org/dist/latest-v10.x/node-v10.24.1-linux-arm64.tar.gz
tar xf node-v10.24.1-linux-arm64.tar.gz -C /usr/local/
vim /etc/profile
export PATH=$PATH:/usr/local/nodejs/bin

node -v 
```



### 3. yapi搭建

```
npm install -g yapi-cli --registry https://registry.npm.taobao.org
yapi server
```



### 4. Libreoffice

```
yum -y install ibus > /dev/null
wget https://ssy-ops.oss-cn-shenzhen.aliyuncs.com/packages/LibreOffice_6.4.6_Linux_x86-64_rpm.tar.gz
tar -xf LibreOffice_6.4.6_Linux_x86-64_rpm.tar.gz
yum -y localinstall LibreOffice_6.4.6.2_Linux_x86-64_rpm/RPMS/*.rpm
echo "export LibreOffice_PATH=/opt/libreoffice6.4/program" >> /etc/profile
echo "export PATH=$LibreOffice_PATH:$PATH" >> /etc/profile
source /etc/profile

```

