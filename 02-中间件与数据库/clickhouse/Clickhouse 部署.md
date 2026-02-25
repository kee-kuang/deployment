# Clickhouse 部署

### 1. Centos 在线部署 clickhouse-server-23.12.6.19

```
1. yum安装 
yum install -y yum-utils
yum-config-manager --add-repo https://packages.clickhouse.com/rpm/clickhouse.repo
yum install -y clickhouse-server-23.12.6.19 clickhouse-client-23.12.6.19

1.1 tar 包安装
存储库：https://packages.clickhouse.com/tgz/
脚本：
LATEST_VERSION=$(curl -s https://packages.clickhouse.com/tgz/stable/ | \
    grep -Eo '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | sort -V -r | head -n 1)
export LATEST_VERSION

case $(uname -m) in
  x86_64) ARCH=amd64 ;;
  aarch64) ARCH=arm64 ;;
  *) echo "Unknown architecture $(uname -m)"; exit 1 ;;
esac

for PKG in clickhouse-common-static clickhouse-common-static-dbg clickhouse-server clickhouse-client
do
  curl -fO "https://packages.clickhouse.com/tgz/stable/$PKG-$LATEST_VERSION-${ARCH}.tgz" \
    || curl -fO "https://packages.clickhouse.com/tgz/stable/$PKG-$LATEST_VERSION.tgz"
done

tar -xzvf "clickhouse-common-static-$LATEST_VERSION-${ARCH}.tgz" \
  || tar -xzvf "clickhouse-common-static-$LATEST_VERSION.tgz"
sudo "clickhouse-common-static-$LATEST_VERSION/install/doinst.sh"

tar -xzvf "clickhouse-common-static-dbg-$LATEST_VERSION-${ARCH}.tgz" \
  || tar -xzvf "clickhouse-common-static-dbg-$LATEST_VERSION.tgz"
sudo "clickhouse-common-static-dbg-$LATEST_VERSION/install/doinst.sh"

tar -xzvf "clickhouse-server-$LATEST_VERSION-${ARCH}.tgz" \
  || tar -xzvf "clickhouse-server-$LATEST_VERSION.tgz"
sudo "clickhouse-server-$LATEST_VERSION/install/doinst.sh" configure
sudo /etc/init.d/clickhouse-server start

tar -xzvf "clickhouse-client-$LATEST_VERSION-${ARCH}.tgz" \
  || tar -xzvf "clickhouse-client-$LATEST_VERSION.tgz"
sudo "clickhouse-client-$LATEST_VERSION/install/doinst.sh"


2. 启动
/etc/init.d/clickhouse-server start
clickhouse-client
/etc/init.d/clickhouse-server restart

3. 创建用户
vim /etc/clickhouse-server/users.d/admin.xml
<yandex>  #xml 的根元素。表明这个配置文件是用于Yandex的数据库系统
  <users>  # 包含所有用户的配置列表
    <admin>  # 定义一个名为admin的用户
      <password>Shushangyun520@</password>   #使用明文设置admin的密码
      <networks>  # 定义允许访问的用户网络
        <ip>::/0</ip>  # 表示所有ip 都可以访问 
      </networks>  
      <profile>default</profile>  #指定用户使用的配额为默认配额
      <quota>default</quota>   #设置为1表示允许用户查看所有数据库
      <access_management>1</access_management>  # 设置为1 表示启动访问管理功能
      <show_databases>1</show_databases>  #设置为1 表示允许用户查看所有数据库
      <allow_ddl>1</allow_ddl>  # 设置为1 表示允许用户执行数据库ddl 操作
      <allow_introspection_functions>1</allow_introspection_functions>  #表示允许用户使用内置函数
      <readonly>0</readonly>  #设置为 0 表示用户不是只读的，可以执行写操作
    </admin>
  </users>
</yandex>

4. 连接客户端
clickhouse-client 
clickhouse-client --host 127.0.0.1 --port 9001 -user default --password 123   //-user 为指定使用哪个账号进行登录，如不指定。默认使用default

```



### 2. clk部署

```

```

