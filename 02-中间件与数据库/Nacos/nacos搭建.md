# nacos搭建

## 一、jdk安装

### 1.1 下载jdk版本

```
　1.下载地址
　wget 
　
```

### 1.2 配置环境变量

```
export JAVA_HOME=/usr/local/jdk1.8.0_241
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export LibreOffice_PATH=/opt/libreoffice6.4/program
export PATH=$LibreOffice_PATH:$PATH
export PATH=$PATH:/usr/local/nodejs/bin
```

### 1.3 测试jdk版本

```
java -version
```

## 二、mysql 安装

### 2.1 下载mysql Yum或者安装包

```
wget https://dev.mysql.com/get/mysql80-community-release-el7-11.noarch.rpm //centos7 yum安装包
```

### 2.2 yum安装 mysql-Yum包

```
yum localinstall mysql80-community-release-el7-11.noarch.rpm
yum -y install mysql 
yum install -y mysql-community-server

```

### 2.3 修改 mysql密码并授权

 注意：8.0版本需要先创建用户，再授权

```
alter user 'root'@'localhost' identified by '2P8ZiVb20Yna3DV1';
create user 'root'@'%' identified by '}M7VwgK.k@';
GRANT ALL ON *.* TO 'root'@'%';
flush privileges;
```

# 三、安装nacos （单机）

## 3.1 下载nacos 安装包

```
1.nacos 版本地址：https://github.com/alibaba/nacos/releases
wget https://github.com/alibaba/nacos/releases/download/2.1.2/nacos-server-2.1.2.zip
2.nacos地址下载
wget https://keekuang.oss-cn-guangzhou.aliyuncs.com/packet/Nacos/nacos-server-2.2.2.zip
https://ssy-ops.oss-cn-shenzhen.aliyuncs.com/packages/nacos-server-2.1.1.zip

## 3.2配置文件修改

```
1.vim application.properties
spring.datasource.platform=mysql
db.num=1
db.url.0=jdbc:mysql://127.0.0.1:3306/nacos?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useUnicode=true&useSSL=false&serverTimezone=UTC
db.user.0=账号
db.password.0=密码
server.tomcat.accesslog.enabled=false
2.编辑conf/nacos-logback.xml
将日志基本为【info】、【INFO】、【debug】、【DEBUG】统一替换为ERROR
将【${nacos.home}/logs】替换为目标存储路径

```

### 3.3 导入数据库

```
create database nacos_config;
use nacos_config;
source mysql-schema.sql;

```

# 四、集群部署
#vim cluster.conf
nacos机器：端口
```

```

# 伍、报错

## 5.1 nacos使用mysql8作为存储媒介时报Caused by: com.mysql.cj.exceptions.CJException: Public Key Retrieval is not all

```
解决方法：
1.在数据库连接url上增加allowPublicKeyRetrieval=true配置
2.使用docker部署增加以下配置
MYSQL_SERVICE_DB_PARAM: characterEncoding=utf8&connectTimeout=2000&allowPublicKeyRetrieval=true&socketTimeout=3000&autoReconnect=true&useUnicode=true&useSSL=false&serverTimezone=UTC

```

# 六、负载均衡

```
## 在http下配置负载
upstream nacoscluster {        
    server 127.0.0.1:8840;
    server 127.0.0.1:8850;
    server 127.0.0.1:8860;
}
http{
	## 在server内配置监听
	server {
		listen       8848;     ## 监听8848端口                 
		server_name  localhost;                                        
		#charset koi8-r;                                                        
		#access_log  logs/host.access.log  main;                                      
		location / {                            
		    #root   html;                       
		    #index  index.html index.htm;       
		    proxy_pass http://nacoscluster;   ## 代理到负载上      
		}
	}
}
stream {
	upstream nacosgrpc {
		server 127.0.0.1:9840;
    	server 127.0.0.1:9850;
    	server 127.0.0.1:9860;
	}
	server {
		listen 9848; # 这里监听的端口是和http内监听的端口对应+1000得到的（8848+1000）
		proxy_pass nacosgrpc;
	}
```


```

### 七、2.2版本

在2.1版本后修复的漏洞
