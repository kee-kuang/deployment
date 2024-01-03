#!/bin/bash
dir=`pwd`

system_init(){
#修改ssh配置文件
#sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config && systemctl restart sshd
#[ $(echo $?) -eq 0 ] && echo "ssh restart success!"

#停止NetworkManager防止与Network冲突
#systemctl stop NetworkManager
#systemctl disable NetworkManager

#修改文件打开数、连接数
ulimit -n 65535
echo "* soft nofile 65535" >> /etc/security/limits.conf
echo "* hard nofile 65535" >> /etc/security/limits.conf

#修改Selinux
#setenforce 0
#sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
#getenforce

#安装基础软件
yum -y install vim wget make gcc gcc-c++ mtr net-tools iptables-services >> /dev/null
[ $(echo $?) -eq 0 ] && echo "basic software install success!"

#创建用户
id www > /dev/null
if [ $? -ne 0 ]
then 
	echo "创建用户www"
	useradd www
else
	echo "用户已存在"
fi
}

jdk_install(){
#安装jdk
tar -xf ./jdk/jdk1.8.0_241.tar.gz -C /usr/local/
echo 'export JAVA_HOME=/usr/local/jdk1.8.0_241' >> /etc/profile
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile
echo 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar' >> /etc/profile
source /etc/profile
java -version > /dev/null
[ $(echo $?) -eq 0 ] && echo "jdk install success!" || echo "jdk install failure!"
}

tengine_install(){
#安装tengine
yum install -y gcc pcre pcre-devel openssl-devel libxml2-devel libxslt-devel gd-devel perl-devel perl-ExtUtils-Embed GeoIP-devel > /dev/null
tar -xf ./tengine/tengine-2.2.0.tar.gz -C ./tengine
cd ./tengine/tengine-2.2.0
./configure --enable-mods-static=all --prefix=/usr/local/nginx --with-ipv6 > /dev/null
[ $(echo $?) -eq 0 ] && make > /dev/null 
[ $(echo $?) -eq 0 ] && make install > /dev/null
[ $(echo $?) -eq 0 ] && echo "nginx install success!" || echo "nginx install failure!"
mkdir /usr/local/nginx/conf/conf.d
cp ../nginx.conf /usr/local/nginx/conf/nginx.conf
cp ../nginx /etc/init.d/nginx
chmod +x /etc/init.d/nginx
chkconfig --add nginx
chkconfig nginx on
service nginx start
[ $(echo $?) -eq 0 ] && echo "nginx start success!" || echo "nginx start failure!"
cd $dir
}

docker_install(){
#安装docker、docker-compose
yum install -y yum-utils device-mapper-persistent-data lvm2 > /dev/null
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo > /dev/null
yum -y install docker-ce > /dev/null
[ $(echo $?) -eq 0 ] && systemctl enable docker >> /dev/null
systemctl start docker
[ $(echo $?) -eq 0 ] && echo "docker start success!" || echo "docker start failure!"
cp ./docker/docker-compose /usr/local/bin/
chmod +x /usr/local/bin/docker-compose
docker-compose -v > /dev/null
[ $(echo $?) -eq 0 ] && echo "docker-compose start success!" || echo "docker-compose start failure!"
}

LibreOffice_install(){
#安装LibreOffice
yum -y install ibus > /dev/null
cd LibreOffice
tar -xf LibreOffice_6.4.6_Linux_x86-64_rpm.tar.gz
yum -y localinstall LibreOffice_6.4.6.2_Linux_x86-64_rpm/RPMS/*.rpm > /dev/null
echo "export LibreOffice_PATH=/opt/libreoffice6.4/program" >> /etc/profile
echo "export PATH=$LibreOffice_PATH:$PATH" >> /etc/profile
source /etc/profile
tar -xf truetype.tar.gz
rm -rf /opt/libreoffice6.4/share/fonts/truetype
mv truetype /opt/libreoffice6.4/share/fonts/
echo "LibreOffice install success"
cd $dir
}

postgresql_install(){
#安装postgresql
yum install -y readline readline-devel openssl openssl-devel zlib zlib-devel > /dev/null
#yum -y install ./postgresql/pgdg-redhat-repo-latest.noarch.rpm > /dev/null
yum -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm > /dev/null
yum -y install postgresql12 postgresql12-server > /dev/null
mkdir -p /data/postgresql/data
chown -R postgres.postgres /data/postgresql
su postgres -c "/usr/pgsql-12/bin/initdb -D /data/postgresql/data/" > /dev/null
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /data/postgresql/data/postgresql.conf
sed -i "s/max_connections = 100/max_connections = 500/g" /data/postgresql/data/postgresql.conf
echo "host    all             all             0.0.0.0/0               md5" >> /data/postgresql/data/pg_hba.conf
sed -i 's#PGDATA=/var/lib/pgsql/12/data/#PGDATA=/data/postgresql/data/#g' /usr/lib/systemd/system/postgresql-12.service
systemctl daemon-reload
systemctl enable postgresql-12
systemctl start postgresql-12
[ $(echo $?) -eq 0 ] && echo "postgresql-12 start success!" || echo "postgresql-12 start failure!"
}

nodejs_install(){
#安装nodejs
cd nodejs
tar -xf node-v16.5.0-linux-x64.tar.gz -C /usr/local
ln -s /usr/local/node-v16.5.0-linux-x64/ /usr/local/nodejs
echo "export PATH=$PATH:/usr/local/nodejs/bin" >> /etc/profile
source /etc/profile
node -v
npm -v
[ $(echo $?) -eq 0 ] && echo "nodejs install success!" || echo "nodejs install failure!"
#安装pm2
npm install pm2 -g  >> /dev/null
[ $(echo $?) -eq 0 ] && echo "pm2 install success!" || echo "pm2 install failure!"
pm2 -v
pm2 startup
pm2 list
#安装yarn
npm install yarn -g  >> /dev/null
[ $(echo $?) -eq 0 ] && echo "yarn install success!" || echo "yarn install failure!"
yarn -v
}

#创建es目录


create_dir(){
mkdir -p /data/es/{bin,config,data,logs} #创建es映射目录
mkdir -p /data/{rabbitmq,redis,nacos}
chmod 775 -R /data/es
cp redis.conf /data/redis/
}



#system_init
#jdk_install
#tengine_install
#docker_install
#LibreOffice_install
#postgresql_install
#nodejs_install
create_dir
