## Yapi 搭建

### 1. 需要部署的中间件

   1. node,js

   2. mongodb

   3. yapi
 
      

      ### 2. 部署Node.js

      ```
      1. 下载Node.js包
      # wget https://npm.taobao.org/mirrors/node/v10.14.1/node-v10.14.1-linux-x64.tar.gz
      2. 解压并软链到/usr/local目录
      # tar xf node-v10.14.1-linux-x64.tar.gz
      # ln -s /usr/local/node-v10.14.1-linux-x64.tar.gz /usr/local/nodejs
      3. 配置环境变量
      # echo "export PATH=$PATH:/usr/local/nodejs/bin" >> /etc/profile
      # source /etc/profile
      4. 验证是否生效
      node -v 
      npm -v
      ```

      

### 3. 部署Mongodb

```
1. 导入mongodb repo仓库
# vim /etc/yum.repo/mongodb.repo
[mongodb-org-6.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/7Server/mongodb-org/6.0/x86_64
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-6.0.asc
# yum makecache
2. 安装 Mongodb 
# yum -y install mongodb-org
# systemctl start mongod.service
# 
```



### 4. 安装yapi 

```
npm install -g yapi-cli --registry https://registry.npm.taobao.org
yapi server

```

