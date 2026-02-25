# 基于Docker 构建 Jenkins CI平台

## 1、部署gitlab 

```
mkdir gitlab
cd gitlab
docker run -d \
   --name gitlab \
   -p 8443:8443 \
   -p 9999:80 \
   -p 9998:22 \
   -v $PWD/config:/etc/gitlab \
   -v $PWD/logs:/var/log/gitlab \
   -v $PWD/data:/var/opt/gitlab \
   -v /etc/localtime:/etc/localtime \
   --restart=always \
   gitlab/gitlab-ce：latest
```

 访问地址：ip:9999

初次会先设置管理员密码，然后登录，默认的管理员用户名root ，密码是设置的

### 1.2、创建项目，提交测试代码

进入后先创建项目，提交代码，解压演示包，以便测试

```
unzip tomcat-java-demo-master.zip
cd tomcat-java-demo-master
git init
git remote add origin 路径
git add .
git config --global user.email "账号"
git config --global user.name "账号"
git commit -m "all"
git pull orrgin master
```



## 2、部署Harbor 镜像仓库

### 2.1安装docker与docker-compose 

```

```

### 2.2 解压离线包部署

```
tar zcvf harbor-offline-installer-v2.0.0.tgz
cd harbor 
cp harbor.yml.tmpl harbor.yml
vi harbor.yml
hostname:reg.ctnrs.com
https:   #先注释https相关配置
harbor_admin_password: Harbor1234

./prepare
./install.sh

```

### 2.3 在Jenkins 主机配置Docker 可信任，如果是HTTPS 需要拷贝证书

