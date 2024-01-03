# docker安装mongodb分片集群

#### 搭建ConfigServer

首先我们搭建两个config-server

创建两个config-server的配置文件

```bash
#创建网桥
docker network create --subnet=172.172.4.0/24 mongo-br0
#创建config-server-1
mkdir -p /data/docker/mongo-cluster/mongo-server1/{data,conf}

#创建config-server-2
mkdir -p /data/docker/mongo-cluster/mongo-server2/{data,conf}

#创建config-server-3
mkdir -p /data/docker/mongo-cluster/mongo-server3/{data,conf}
```

然后配置文件中配置端口

```bash
#创建第一个配置文件
#写入配置信息，端口号

echo "# mongodb.conf
logappend=true
# bind_ip=127.0.0.1
port=20011
auth=false" > /data/docker/mongo-cluster/mongo-server1/conf/mongo.conf

#创建第二个配置文件
#写入配置信息，端口号

echo "# mongodb.conf
logappend=true
# bind_ip=127.0.0.1
port=20012
auth=false" > /data/docker/mongo-cluster/mongo-server2/conf/mongo.conf

#创建第三个配置文件
#写入配置信息，端口号

echo "# mongodb.conf
logappend=true
# bind_ip=127.0.0.1
port=20013
auth=false" > /data/docker/mongo-cluster/mongo-server3/conf/mongo.conf
```

然后启动容器

```bash
#启动Server1

docker run --name mongo-server1 -d \
--net=mongo-br0 \
--ip=172.172.4.10 \
--privileged=true \
-m 512m \
-e TZ=Asia/Shanghai \
-v /data/docker/mongo-cluster/mongo-server1/conf:/data/configdb \
-v /data/docker/mongo-cluster/mongo-server1/data:/data/db \
docker.io/mongo:6.0.5 mongod -f /data/configdb/mongo.conf --configsvr --replSet "rs_config_server" --bind_ip_all

docker run --name mongo-server2 -d \
--net=mongo-br0 \
--ip=172.172.4.11 \
--privileged=true \
-m 512m \
-e TZ=Asia/Shanghai \
-v /data/docker/mongo-cluster/mongo-server2/conf:/data/configdb \
-v /data/docker/mongo-cluster/mongo-server2/data:/data/db \
docker.io/mongo:6.0.5 mongod -f /data/configdb/mongo.conf --configsvr --replSet "rs_config_server" --bind_ip_all


docker run --name mongo-server3 -d \
--net=mongo-br0 \
--ip=172.172.4.12 \
--privileged=true \
-m 512m \
-e TZ=Asia/Shanghai \
-v /data/docker/mongo-cluster/mongo-server3/conf:/data/configdb \
-v /data/docker/mongo-cluster/mongo-server3/data:/data/db \
docker.io/mongo:6.0.5 mongod -f /data/configdb/mongo.conf --configsvr --replSet "rs_config_server" --bind_ip_all
```

然后进入容器初始化

```bash
#进入容器
docker exec -it mongo-server1 bash

mongo -port 20011

#初始化
rs.initiate(
{
_id: "rs_config_server",
configsvr: true,
members: [
{ _id : 0, host : "172.172.4.10:20011" },
{ _id : 1, host : "172.172.4.11:20012" },
{ _id : 2, host : "172.172.4.12:20013" }
]
}
);


```

如果ok为1表示成功

#### 创建分片集群

下面我们给每个server创建2个分片

创建挂载文件

```bash
#创建config-server-1的两个分片目录
mkdir -p /data/docker/mongo-cluster/mongo-server1-shard1/{data,conf}
mkdir -p /data/docker/mongo-cluster/mongo-server1-shard2/{data,conf}

#创建config-server-2的两个分片目录
mkdir -p /data/docker/mongo-cluster/mongo-server2-shard1/{data,conf}
mkdir -p /data/docker/mongo-cluster/mongo-server2-shard2/{data,conf}

#创建config-server-2的两个分片目录
mkdir -p /data/docker/mongo-cluster/mongo-server3-shard1/{data,conf}
mkdir -p /data/docker/mongo-cluster/mongo-server3-shard2/{data,conf}
```

创建配置文件

```bash
#创建config-server-1的两个分片配置文件

echo "# mongodb.conf
logappend=true
# bind_ip=127.0.0.1
port=20021
auth=false" > /data/docker/mongo-cluster/mongo-server1-shard1/conf/mongo.conf

echo "# mongodb.conf
logappend=true
# bind_ip=127.0.0.1
port=20022
auth=false" > /data/docker/mongo-cluster/mongo-server1-shard2/conf/mongo.conf
#创建config-server-2的两个分片配置文件

echo "# mongodb.conf
logappend=true
# bind_ip=127.0.0.1
port=20023
auth=false" > /data/docker/mongo-cluster/mongo-server2-shard1/conf/mongo.conf

echo "# mongodb.conf
logappend=true
# bind_ip=127.0.0.1
port=20024
auth=false" > /data/docker/mongo-cluster/mongo-server2-shard2/conf/mongo.conf

echo "# mongodb.conf
logappend=true
# bind_ip=127.0.0.1
port=20025
auth=false" > /data/docker/mongo-cluster/mongo-server3-shard1/conf/mongo.conf

echo "# mongodb.conf
logappend=true
# bind_ip=127.0.0.1
port=20026
auth=false" > /data/docker/mongo-cluster/mongo-server3-shard2/conf/mongo.conf
```

然后启动容器

```bash
#启动config-server-1的两个分片容器
docker run --name mongo-server1-shard1 -d \
--net=mongo-br0 \
--ip=172.172.4.15 \
--privileged=true \
-m 512m \
-e TZ=Asia/Shanghai \
-v /data/docker/mongo-cluster/mongo-server1-shard1/conf:/data/configdb \
-v /data/docker/mongo-cluster/mongo-server1-shard1/data:/data/db \
docker.io/mongo:6.0.5 mongod -f /data/configdb/mongo.conf --shardsvr --replSet "rs_shard_server1" --bind_ip_all

docker run --name mongo-server1-shard2 -d \
--net=mongo-br0 \
--ip=172.172.4.16 \
--privileged=true \
-m 512m \
-e TZ=Asia/Shanghai \
-v /data/docker/mongo-cluster/mongo-server1-shard2/conf:/data/configdb \
-v /data/docker/mongo-cluster/mongo-server1-shard2/data:/data/db \
docker.io/mongo:6.0.5 mongod -f /data/configdb/mongo.conf --shardsvr --replSet "rs_shard_server1" --bind_ip_all

#启动config-server-2的两个分片容器
docker run --name mongo-server2-shard1 -d \
--net=mongo-br0 \
--ip=172.172.4.17 \
-m 512m \
--privileged=true \
-e TZ=Asia/Shanghai \
-v /data/docker/mongo-cluster/mongo-server2-shard1/conf:/data/configdb \
-v /data/docker/mongo-cluster/mongo-server2-shard1/data:/data/db \
docker.io/mongo:6.0.5 mongod -f /data/configdb/mongo.conf --shardsvr --replSet "rs_shard_server2" --bind_ip_all


docker run --name mongo-server2-shard2 -d \
--net=mongo-br0 \
--ip=172.172.4.18 \
-m 512m \
--privileged=true \
-e TZ=Asia/Shanghai \
-v /data/docker/mongo-cluster/mongo-server2-shard2/conf:/data/configdb \
-v /data/docker/mongo-cluster/mongo-server2-shard2/data:/data/db \
docker.io/mongo:6.0.5 mongod -f /data/configdb/mongo.conf --shardsvr --replSet "rs_shard_server2" --bind_ip_all

#启动config-server-3的两个分片容器
docker run --name mongo-server3-shard1 -d \
--net=mongo-br0 \
--ip=172.172.4.19 \
--privileged=true \
-m 512m \
-e TZ=Asia/Shanghai \
-v /data/docker/mongo-cluster/mongo-server3-shard1/conf:/data/configdb \
-v /data/docker/mongo-cluster/mongo-server3-shard1/data:/data/db \
docker.io/mongo:6.0.5 mongod -f /data/configdb/mongo.conf --shardsvr --replSet "rs_shard_server3" --bind_ip_all


docker run --name mongo-server3-shard2 -d \
--net=mongo-br0 \
--ip=172.172.4.20 \
--privileged=true \
-m 512m \
-e TZ=Asia/Shanghai \
-v /data/docker/mongo-cluster/mongo-server3-shard2/conf:/data/configdb \
-v /data/docker/mongo-cluster/mongo-server3-shard2/data:/data/db \
docker.io/mongo:6.0.5 mongod -f /data/configdb/mongo.conf --shardsvr --replSet "rs_shard_server3" --bind_ip_all

```

### 注意如果有多的分片`--replSet "rs_shard_server"` 需要更改，否则添加不成功

进入第一个分片

```bash
 docker exec  -it mongo-server1-shard1 bash
 mongosh -port 20021
 
#进行分片
 rs.initiate(
{
_id : "rs_shard_server1",
members: [
{ _id : 0, host : "172.172.4.15:20021" },
{ _id : 1, host : "172.172.4.16:20022" },
]
}
);
```

进入第二个分片

```bash
 docker exec  -it mongo-server2-shard1 bash
 mongosh -port 20023
 
 #进行分片
 rs.initiate(
{
_id : "rs_shard_server2",
members: [
{ _id : 0, host : "172.172.4.17:20023" },
{ _id : 1, host : "172.172.4.18:20024" }
]
}
);
```

进入第三个分片

```shell
 docker exec  -it mongo-server3-shard1 bash
 mongosh -port 20025
 
 #进行分片
 rs.initiate(
{
_id : "rs_shard_server3",
members: [
{ _id : 0, host : "172.172.4.19:20025" },
{ _id : 1, host : "172.172.4.20:20026" }
]
}
);
```



#### 安装Mongos

创建挂载文件

```bash
mkdir -p /data/docker/mongo-cluster/mongos1/{data,conf}

echo "# mongodb.conf
logappend=true
# bind_ip=127.0.0.1
port=20099
auth=false" > /data/docker/mongo-cluster/mongos1/conf/mongo.conf
```

然后启动Mongo

```bash
docker run --name mongo-mongos1 -d \
--net=mongo-br0 \
--ip=172.172.4.21 \
--privileged=true \
-p 27017:27017 \
-m 1024m \
-e TZ=Asia/Shanghai \
--entrypoint "mongos" \
-v /data/docker/mongo-cluster/mongos1/conf:/data/configdb \
-v /data/docker/mongo-cluster/mongos1/data:/data/db \
docker.io/mongo:6.0.5 \
--configdb rs_config_server/172.172.4.10:20011,172.172.4.11:20012,172.172.4.12:20013 --bind_ip_all
```

mongo添加分片组

```shell
docker exec -it mongo-mongos1 bash
mongosh -port 27017


sh.addShard("rs_shard_server1/172.172.4.15:20021,172.172.4.16:20022")
sh.addShard("rs_shard_server2/172.172.4.17:20023,172.172.4.18:20024")
sh.addShard("rs_shard_server2/172.172.4.19:20025,172.172.4.20:20026")
```

新建数据启用分片

```stata
sh.enableSharding("IOT_DATA")

对IOT_DATA.order的_id进行哈希分片
sh.shardCollection("IOT_DATA.order", {"_id": "hashed" })
插入数据后查看分片数据
use IOT_DATA
for (i = 1; i <= 1000; i=i+1){db.order.insert({'price': 1})}
```

### Mongo分片集群高可用+权限（推荐）

那么我们先来总结一下我们搭建一个高可用集群需要多少个Mongo

mongos ： 3台

configserver ： 3台

shard ： 3片

每一片shard 分别 部署两个副本集和一个仲裁节点 ： 3台

那么就是 3 + 3 + 3 * 3 = 15 台，我这里演示采用3台服务器

 114.67.80.169 4核16g 部署一个configserver，一个mongos，2个分片组

 182.61.2.16 2核4g 部署一个configserver，一个mongos，1个分片组

 106.12.113.62 1核2g 部署一个configserver，一个mongos，不搭建分片组

由于此处服务器原因所以不是均衡分布，请根据自身实际情况搭建

|      角色      |      ip       | 端口  |
| :------------: | :-----------: | :---: |
| config-server1 | 114.67.80.169 | 20011 |
| config-server2 |  182.61.2.16  | 20012 |
| config-server3 | 106.12.113.62 | 20013 |
|    mongos1     | 114.67.80.169 | 20021 |
|    mongos2     |  182.61.2.16  | 20022 |
|    mongos3     | 106.12.113.62 | 20023 |
| shard1-server1 | 114.67.80.169 | 20031 |
| shard1-server2 | 114.67.80.169 | 20032 |
| shard1-server3 | 114.67.80.169 | 20033 |
| shard2-server1 | 114.67.80.169 | 20034 |
| shard2-server2 | 114.67.80.169 | 20035 |
| shard2-server3 | 114.67.80.169 | 20036 |
| shard3-server1 |  182.61.2.16  | 20037 |
| shard3-server2 |  182.61.2.16  | 20038 |
| shard3-server3 |  182.61.2.16  | 20039 |

#### 搭建ConfigServer

 我们先来搭建ConfigServer，因为我们知道搭建的话一定要高可用而且一定要权限这里mongo之间通信采用秘钥文件，所以我们先进行生成

##### 搭建config-server1

创建挂载文件目录

```bash
mkdir -p /docker/mongo-cluster/config-server1/{data,conf}
```

写入配置文件

```bash
echo "
# 日志文件
#systemLog:
#  destination: file
#  logAppend: true
#  path: /var/log/mongodb/data0802.log

#  网络设置
net:
  port: 20011  #端口号
#  bindIp: 127.0.0.1    #绑定ip
replication:
  replSetName: configsvr
sharding:
  clusterRole: configsvr
security:
  authorization: enabled #是否开启认证
  keyFile: /data/configdb/mongo.key #keyFile路径 "  > /docker/mongo-cluster/config-server1/conf/mongo.conf
```

然后生成keyFile

```awk
openssl rand -base64 756  > /docker/mongo-cluster/config-server1/conf/mongo.key
```

文件如下，我们，之后我们所以key都采用这个（请采用自己生成的key）

```bash
tsUtJb3TeueNR8Mehr7ZLmZx82qfuCQ7LfLjUvQA7hNfWSomyNDISXDiSTJQEVym
OhXXzwB+0iv+czxi4qe9tAP8fMDuXpieZreysg4gxZ1VoFC1q39IrUDAEpCikSKS
abGl8RTEOM/GzVM8BATjaGHuBIi2osBAPg2Hzi+/u9ORbb4I4jzvgStcPcozRgOZ
5kPvXBybanV8MhLA6MfG1rcUiTkGoKb65YuWIfPuuF7PTWZe4VcF+iU6jgw73juZ
pbcZR5oTKvOWz89KCRTmQqHRexmJyn+NJcIGHFS/sZSJXE8LFPBZ+XLGYrtmDqo0
9tA1x8R+u32OJ7iOAU1mFkCHe2Uoph6aeVx/jZx1FgFjW0afT4ou2w7QHsdF0WRn
nskJ1FCA8NKzhYYgv/YrpyAChhTgd//gbWr028qz1W1POpBkj4muKUk7OTHRV6bs
qr2C73bqcZ1n2s60k6WbRUd6LP6POHR93wvi5EaXyorSMBIGiSD1Kyr/iqO7gD4C
GN8iA3MqF+fW5nKn1yBNEfPGoFk+p0EaxIAhfLEpzSRb3Wt5XLOWP7CBGuTo7KST
Y5HAcblqN7TByQhLdH5MZJ4FhfTZ0yNKTOVQdZUYRb5GGgS0GZfUk4bndLTkHrJd
tcR4WreHpz7ccncE5Vt8TGglrEx0noFVBqLqTdrqFUFpvWoukw/eViacLlBHKOxB
QVgfo4491znNMmthqGimVI7TFV706AvVJGqoIyuiFZRE5qx5MsOlIXiFwA3ue1Lo
kiFq5c6ImvS0R9LGu1Xcr0REYN53/bBVgGzJovEn7IIrHChYow7TkTLf/LsnjL3m
rmkDRgzA0C5i6fXgKkJdBhvvA521Yf75YP9n+819NUTZbtGIxRnP07pMS9RP4TjS
ZSd9an5yc7IpnL0gE4Pmnvf8LM86WTt9hZWKrE2LeQPEFgFl/Eq5NH60Zd4utxfi
qM2FH7aNsEukoAvA2v3All1wsM2kn4fMa89Hwui9h4xMy5tU
```

写入key文件

```bash
echo "tsUtJb3TeueNR8Mehr7ZLmZx82qfuCQ7LfLjUvQA7hNfWSomyNDISXDiSTJQEVym
OhXXzwB+0iv+czxi4qe9tAP8fMDuXpieZreysg4gxZ1VoFC1q39IrUDAEpCikSKS
abGl8RTEOM/GzVM8BATjaGHuBIi2osBAPg2Hzi+/u9ORbb4I4jzvgStcPcozRgOZ
5kPvXBybanV8MhLA6MfG1rcUiTkGoKb65YuWIfPuuF7PTWZe4VcF+iU6jgw73juZ
pbcZR5oTKvOWz89KCRTmQqHRexmJyn+NJcIGHFS/sZSJXE8LFPBZ+XLGYrtmDqo0
9tA1x8R+u32OJ7iOAU1mFkCHe2Uoph6aeVx/jZx1FgFjW0afT4ou2w7QHsdF0WRn
nskJ1FCA8NKzhYYgv/YrpyAChhTgd//gbWr028qz1W1POpBkj4muKUk7OTHRV6bs
qr2C73bqcZ1n2s60k6WbRUd6LP6POHR93wvi5EaXyorSMBIGiSD1Kyr/iqO7gD4C
GN8iA3MqF+fW5nKn1yBNEfPGoFk+p0EaxIAhfLEpzSRb3Wt5XLOWP7CBGuTo7KST
Y5HAcblqN7TByQhLdH5MZJ4FhfTZ0yNKTOVQdZUYRb5GGgS0GZfUk4bndLTkHrJd
tcR4WreHpz7ccncE5Vt8TGglrEx0noFVBqLqTdrqFUFpvWoukw/eViacLlBHKOxB
QVgfo4491znNMmthqGimVI7TFV706AvVJGqoIyuiFZRE5qx5MsOlIXiFwA3ue1Lo
kiFq5c6ImvS0R9LGu1Xcr0REYN53/bBVgGzJovEn7IIrHChYow7TkTLf/LsnjL3m
rmkDRgzA0C5i6fXgKkJdBhvvA521Yf75YP9n+819NUTZbtGIxRnP07pMS9RP4TjS
ZSd9an5yc7IpnL0gE4Pmnvf8LM86WTt9hZWKrE2LeQPEFgFl/Eq5NH60Zd4utxfi
qM2FH7aNsEukoAvA2v3All1wsM2kn4fMa89Hwui9h4xMy5tU"  > /docker/mongo-cluster/config-server1/conf/mongo.key

#处理权限为400

chmod 400 /docker/mongo-cluster/config-server1/conf/mongo.key
```

然后启动config-server1容器

```bash
docker run --name mongo-server1 -d \
--net=host \
--privileged=true \
-v /docker/mongo-cluster/config-server1/conf:/data/configdb \
-v /docker/mongo-cluster/config-server1/data:/data/db \
docker.io/mongo:latest mongod -f /data/configdb/mongo.conf
```

##### 搭建config-server2

创建挂载文件目录

```bash
mkdir -p /docker/mongo-cluster/config-server2/{data,conf}
```

写入配置文件

写入配置文件

```bash
echo "
# 日志文件
#systemLog:
#  destination: file
#  logAppend: true
#  path: /var/log/mongodb/data0802.log

#  网络设置
net:
  port: 20012  #端口号
#  bindIp: 127.0.0.1    #绑定ip
replication:
  replSetName: configsvr
sharding:
  clusterRole: configsvr
security:
  authorization: enabled #是否开启认证
  keyFile: /data/configdb/mongo.key #keyFile路径 "  > /docker/mongo-cluster/config-server2/conf/mongo.conf
```

文件如下，我们，之后我们所以key都采用这个（请采用自己生成的key）

写入key文件

```bash
echo "tsUtJb3TeueNR8Mehr7ZLmZx82qfuCQ7LfLjUvQA7hNfWSomyNDISXDiSTJQEVym
OhXXzwB+0iv+czxi4qe9tAP8fMDuXpieZreysg4gxZ1VoFC1q39IrUDAEpCikSKS
abGl8RTEOM/GzVM8BATjaGHuBIi2osBAPg2Hzi+/u9ORbb4I4jzvgStcPcozRgOZ
5kPvXBybanV8MhLA6MfG1rcUiTkGoKb65YuWIfPuuF7PTWZe4VcF+iU6jgw73juZ
pbcZR5oTKvOWz89KCRTmQqHRexmJyn+NJcIGHFS/sZSJXE8LFPBZ+XLGYrtmDqo0
9tA1x8R+u32OJ7iOAU1mFkCHe2Uoph6aeVx/jZx1FgFjW0afT4ou2w7QHsdF0WRn
nskJ1FCA8NKzhYYgv/YrpyAChhTgd//gbWr028qz1W1POpBkj4muKUk7OTHRV6bs
qr2C73bqcZ1n2s60k6WbRUd6LP6POHR93wvi5EaXyorSMBIGiSD1Kyr/iqO7gD4C
GN8iA3MqF+fW5nKn1yBNEfPGoFk+p0EaxIAhfLEpzSRb3Wt5XLOWP7CBGuTo7KST
Y5HAcblqN7TByQhLdH5MZJ4FhfTZ0yNKTOVQdZUYRb5GGgS0GZfUk4bndLTkHrJd
tcR4WreHpz7ccncE5Vt8TGglrEx0noFVBqLqTdrqFUFpvWoukw/eViacLlBHKOxB
QVgfo4491znNMmthqGimVI7TFV706AvVJGqoIyuiFZRE5qx5MsOlIXiFwA3ue1Lo
kiFq5c6ImvS0R9LGu1Xcr0REYN53/bBVgGzJovEn7IIrHChYow7TkTLf/LsnjL3m
rmkDRgzA0C5i6fXgKkJdBhvvA521Yf75YP9n+819NUTZbtGIxRnP07pMS9RP4TjS
ZSd9an5yc7IpnL0gE4Pmnvf8LM86WTt9hZWKrE2LeQPEFgFl/Eq5NH60Zd4utxfi
qM2FH7aNsEukoAvA2v3All1wsM2kn4fMa89Hwui9h4xMy5tU"  > /docker/mongo-cluster/config-server2/conf/mongo.key

#处理权限为400

chmod 400 /docker/mongo-cluster/config-server2/conf/mongo.key
```

然后启动config-server2容器

```bash
docker run --name mongo-server2 -d \
--net=host \
--privileged=true \
-v /docker/mongo-cluster/config-server2/conf:/data/configdb \
-v /docker/mongo-cluster/config-server2/data:/data/db \
docker.io/mongo:latest mongod -f /data/configdb/mongo.conf
```

##### 搭建config-server3

创建挂载文件目录

```bash
mkdir -p /docker/mongo-cluster/config-server3/{data,conf}
```

写入配置文件

```bash
echo "
# 日志文件
#systemLog:
#  destination: file
#  logAppend: true
#  path: /var/log/mongodb/data0802.log

#  网络设置
net:
  port: 20013  #端口号
#  bindIp: 127.0.0.1    #绑定ip
replication:
  replSetName: configsvr
sharding:
  clusterRole: configsvr
security:
  authorization: enabled #是否开启认证
  keyFile: /data/configdb/mongo.key #keyFile路径 "  > /docker/mongo-cluster/config-server3/conf/mongo.conf
```

文件如下，我们，之后我们所以key都采用这个（请采用自己生成的key）

写入key文件

```bash
echo "tsUtJb3TeueNR8Mehr7ZLmZx82qfuCQ7LfLjUvQA7hNfWSomyNDISXDiSTJQEVym
OhXXzwB+0iv+czxi4qe9tAP8fMDuXpieZreysg4gxZ1VoFC1q39IrUDAEpCikSKS
abGl8RTEOM/GzVM8BATjaGHuBIi2osBAPg2Hzi+/u9ORbb4I4jzvgStcPcozRgOZ
5kPvXBybanV8MhLA6MfG1rcUiTkGoKb65YuWIfPuuF7PTWZe4VcF+iU6jgw73juZ
pbcZR5oTKvOWz89KCRTmQqHRexmJyn+NJcIGHFS/sZSJXE8LFPBZ+XLGYrtmDqo0
9tA1x8R+u32OJ7iOAU1mFkCHe2Uoph6aeVx/jZx1FgFjW0afT4ou2w7QHsdF0WRn
nskJ1FCA8NKzhYYgv/YrpyAChhTgd//gbWr028qz1W1POpBkj4muKUk7OTHRV6bs
qr2C73bqcZ1n2s60k6WbRUd6LP6POHR93wvi5EaXyorSMBIGiSD1Kyr/iqO7gD4C
GN8iA3MqF+fW5nKn1yBNEfPGoFk+p0EaxIAhfLEpzSRb3Wt5XLOWP7CBGuTo7KST
Y5HAcblqN7TByQhLdH5MZJ4FhfTZ0yNKTOVQdZUYRb5GGgS0GZfUk4bndLTkHrJd
tcR4WreHpz7ccncE5Vt8TGglrEx0noFVBqLqTdrqFUFpvWoukw/eViacLlBHKOxB
QVgfo4491znNMmthqGimVI7TFV706AvVJGqoIyuiFZRE5qx5MsOlIXiFwA3ue1Lo
kiFq5c6ImvS0R9LGu1Xcr0REYN53/bBVgGzJovEn7IIrHChYow7TkTLf/LsnjL3m
rmkDRgzA0C5i6fXgKkJdBhvvA521Yf75YP9n+819NUTZbtGIxRnP07pMS9RP4TjS
ZSd9an5yc7IpnL0gE4Pmnvf8LM86WTt9hZWKrE2LeQPEFgFl/Eq5NH60Zd4utxfi
qM2FH7aNsEukoAvA2v3All1wsM2kn4fMa89Hwui9h4xMy5tU"  > /docker/mongo-cluster/config-server3/conf/mongo.key

#处理权限为400

chmod 400 /docker/mongo-cluster/config-server3/conf/mongo.key
```

然后启动config-server3容器

```bash
docker run --name mongo-server3 -d \
--net=host \
--privileged=true \
-v /docker/mongo-cluster/config-server3/conf:/data/configdb \
-v /docker/mongo-cluster/config-server3/data:/data/db \
docker.io/mongo:latest mongod -f /data/configdb/mongo.conf
```

##### 初始化config-server

进入第一台容器

```apache
docker exec -it mongo-server1 bash
mongo -port 20011
```

输入

```sqf
rs.initiate(
  {
    _id: "configsvr",
    members: [
      { _id : 1, host : "114.67.80.169:20011" },
      { _id : 2, host : "182.61.2.16:20012" },
      { _id : 3, host : "106.12.113.62:20013" }
    ]
  }
)
```

如果返回ok则成功

然后我们创建用户

```bash
use admin
db.createUser({user:"root",pwd:"root",roles:[{role:'root',db:'admin'}]})
```

#### 搭建Shard分片组

 由于mongos是客户端，所以我们先搭建好config以及shard之后再搭建mongos。

##### 搭建shard1分片组

在同一台服务器上初始化一组分片

创建挂载文件

```bash
mkdir -p /docker/mongo-cluster/shard1-server1/{data,conf}
mkdir -p /docker/mongo-cluster/shard1-server2/{data,conf}
mkdir -p /docker/mongo-cluster/shard1-server3/{data,conf}
```

配置配置文件

```bash
echo "
# 日志文件
#systemLog:
#  destination: file
#  logAppend: true
#  path: /var/log/mongodb/data0802.log

#  网络设置
net:
  port: 20031  #端口号
#  bindIp: 127.0.0.1    #绑定ip
replication:
  replSetName: shard1
sharding:
  clusterRole: shardsvr
security:
  authorization: enabled #是否开启认证
  keyFile: /data/configdb/mongo.key #keyFile路径 "  > /docker/mongo-cluster/shard1-server1/conf/mongo.conf
------------------------------------------------------------------------------
echo "
# 日志文件
#systemLog:
#  destination: file
#  logAppend: true
#  path: /var/log/mongodb/data0802.log

#  网络设置
net:
  port: 20032  #端口号
#  bindIp: 127.0.0.1    #绑定ip
replication:
  replSetName: shard1
sharding:
  clusterRole: shardsvr
security:
  authorization: enabled #是否开启认证
  keyFile: /data/configdb/mongo.key #keyFile路径 "  > /docker/mongo-cluster/shard1-server2/conf/mongo.conf
------------------------------------------------------------------------------
echo "
# 日志文件
#systemLog:
#  destination: file
#  logAppend: true
#  path: /var/log/mongodb/data0802.log

#  网络设置
net:
  port: 20033  #端口号
#  bindIp: 127.0.0.1    #绑定ip
replication:
  replSetName: shard1
sharding:
  clusterRole: shardsvr
security:
  authorization: enabled #是否开启认证
  keyFile: /data/configdb/mongo.key #keyFile路径 "  > /docker/mongo-cluster/shard1-server3/conf/mongo.conf
```

创建keyfile

```bash
echo "tsUtJb3TeueNR8Mehr7ZLmZx82qfuCQ7LfLjUvQA7hNfWSomyNDISXDiSTJQEVym
OhXXzwB+0iv+czxi4qe9tAP8fMDuXpieZreysg4gxZ1VoFC1q39IrUDAEpCikSKS
abGl8RTEOM/GzVM8BATjaGHuBIi2osBAPg2Hzi+/u9ORbb4I4jzvgStcPcozRgOZ
5kPvXBybanV8MhLA6MfG1rcUiTkGoKb65YuWIfPuuF7PTWZe4VcF+iU6jgw73juZ
pbcZR5oTKvOWz89KCRTmQqHRexmJyn+NJcIGHFS/sZSJXE8LFPBZ+XLGYrtmDqo0
9tA1x8R+u32OJ7iOAU1mFkCHe2Uoph6aeVx/jZx1FgFjW0afT4ou2w7QHsdF0WRn
nskJ1FCA8NKzhYYgv/YrpyAChhTgd//gbWr028qz1W1POpBkj4muKUk7OTHRV6bs
qr2C73bqcZ1n2s60k6WbRUd6LP6POHR93wvi5EaXyorSMBIGiSD1Kyr/iqO7gD4C
GN8iA3MqF+fW5nKn1yBNEfPGoFk+p0EaxIAhfLEpzSRb3Wt5XLOWP7CBGuTo7KST
Y5HAcblqN7TByQhLdH5MZJ4FhfTZ0yNKTOVQdZUYRb5GGgS0GZfUk4bndLTkHrJd
tcR4WreHpz7ccncE5Vt8TGglrEx0noFVBqLqTdrqFUFpvWoukw/eViacLlBHKOxB
QVgfo4491znNMmthqGimVI7TFV706AvVJGqoIyuiFZRE5qx5MsOlIXiFwA3ue1Lo
kiFq5c6ImvS0R9LGu1Xcr0REYN53/bBVgGzJovEn7IIrHChYow7TkTLf/LsnjL3m
rmkDRgzA0C5i6fXgKkJdBhvvA521Yf75YP9n+819NUTZbtGIxRnP07pMS9RP4TjS
ZSd9an5yc7IpnL0gE4Pmnvf8LM86WTt9hZWKrE2LeQPEFgFl/Eq5NH60Zd4utxfi
qM2FH7aNsEukoAvA2v3All1wsM2kn4fMa89Hwui9h4xMy5tU"  > /docker/mongo-cluster/shard1-server1/conf/mongo.key

#处理权限为400

chmod 400 /docker/mongo-cluster/shard1-server1/conf/mongo.key

#复制
cp /docker/mongo-cluster/shard1-server1/conf/mongo.key /docker/mongo-cluster/shard1-server2/conf/mongo.key

cp /docker/mongo-cluster/shard1-server1/conf/mongo.key /docker/mongo-cluster/shard1-server3/conf/mongo.key
```

运行shard1分片组

```bash
docker run --name shard1-server1 -d \
--net=host \
--privileged=true \
-v /docker/mongo-cluster/shard1-server1/conf:/data/configdb \
-v /docker/mongo-cluster/shard1-server1/data:/data/db \
docker.io/mongo:latest mongod -f /data/configdb/mongo.conf

docker run --name shard1-server2 -d \
--net=host \
--privileged=true \
-v /docker/mongo-cluster/shard1-server2/conf:/data/configdb \
-v /docker/mongo-cluster/shard1-server2/data:/data/db \
docker.io/mongo:latest mongod -f /data/configdb/mongo.conf

docker run --name shard1-server3 -d \
--net=host \
--privileged=true \
-v /docker/mongo-cluster/shard1-server3/conf:/data/configdb \
-v /docker/mongo-cluster/shard1-server3/data:/data/db \
docker.io/mongo:latest mongod -f /data/configdb/mongo.conf
```

##### 初始化shard1分片组

并且制定第三个副本集为仲裁节点

```nginx
 docker exec  -it shard1-server1 bash
 mongo -port 20031
 
#进行副本集配置
 rs.initiate(
{
_id : "shard1",
members: [
{ _id : 0, host : "114.67.80.169:20031" },
{ _id : 1, host : "114.67.80.169:20032" },
{ _id : 2, host : "114.67.80.169:20033",arbiterOnly:true }
]
}
);
```

返回ok后创建用户

```reasonml
use admin
db.createUser({user:"root",pwd:"root",roles:[{role:'root',db:'admin'}]})
```

然后退出，分片组1搭建完成

##### 搭建shard2分片组

在同一台服务器上初始化一组分片

创建挂载文件

```bash
mkdir -p /docker/mongo-cluster/shard2-server1/{data,conf}
mkdir -p /docker/mongo-cluster/shard2-server2/{data,conf}
mkdir -p /docker/mongo-cluster/shard2-server3/{data,conf}
```

配置配置文件

```bash
echo "
# 日志文件
#systemLog:
#  destination: file
#  logAppend: true
#  path: /var/log/mongodb/data0802.log

#  网络设置
net:
  port: 20034  #端口号
#  bindIp: 127.0.0.1    #绑定ip
replication:
  replSetName: shard2
sharding:
  clusterRole: shardsvr
security:
  authorization: enabled #是否开启认证
  keyFile: /data/configdb/mongo.key #keyFile路径 "  > /docker/mongo-cluster/shard2-server1/conf/mongo.conf
------------------------------------------------------------------------------
echo "
# 日志文件
#systemLog:
#  destination: file
#  logAppend: true
#  path: /var/log/mongodb/data0802.log

#  网络设置
net:
  port: 20035  #端口号
#  bindIp: 127.0.0.1    #绑定ip
replication:
  replSetName: shard2
sharding:
  clusterRole: shardsvr
security:
  authorization: enabled #是否开启认证
  keyFile: /data/configdb/mongo.key #keyFile路径 "  > /docker/mongo-cluster/shard2-server2/conf/mongo.conf
------------------------------------------------------------------------------
echo "
# 日志文件
#systemLog:
#  destination: file
#  logAppend: true
#  path: /var/log/mongodb/data0802.log

#  网络设置
net:
  port: 20036  #端口号
#  bindIp: 127.0.0.1    #绑定ip
replication:
  replSetName: shard2
sharding:
  clusterRole: shardsvr
security:
  authorization: enabled #是否开启认证
  keyFile: /data/configdb/mongo.key #keyFile路径 "  > /docker/mongo-cluster/shard2-server3/conf/mongo.conf
```

创建keyfile

```bash
echo "tsUtJb3TeueNR8Mehr7ZLmZx82qfuCQ7LfLjUvQA7hNfWSomyNDISXDiSTJQEVym
OhXXzwB+0iv+czxi4qe9tAP8fMDuXpieZreysg4gxZ1VoFC1q39IrUDAEpCikSKS
abGl8RTEOM/GzVM8BATjaGHuBIi2osBAPg2Hzi+/u9ORbb4I4jzvgStcPcozRgOZ
5kPvXBybanV8MhLA6MfG1rcUiTkGoKb65YuWIfPuuF7PTWZe4VcF+iU6jgw73juZ
pbcZR5oTKvOWz89KCRTmQqHRexmJyn+NJcIGHFS/sZSJXE8LFPBZ+XLGYrtmDqo0
9tA1x8R+u32OJ7iOAU1mFkCHe2Uoph6aeVx/jZx1FgFjW0afT4ou2w7QHsdF0WRn
nskJ1FCA8NKzhYYgv/YrpyAChhTgd//gbWr028qz1W1POpBkj4muKUk7OTHRV6bs
qr2C73bqcZ1n2s60k6WbRUd6LP6POHR93wvi5EaXyorSMBIGiSD1Kyr/iqO7gD4C
GN8iA3MqF+fW5nKn1yBNEfPGoFk+p0EaxIAhfLEpzSRb3Wt5XLOWP7CBGuTo7KST
Y5HAcblqN7TByQhLdH5MZJ4FhfTZ0yNKTOVQdZUYRb5GGgS0GZfUk4bndLTkHrJd
tcR4WreHpz7ccncE5Vt8TGglrEx0noFVBqLqTdrqFUFpvWoukw/eViacLlBHKOxB
QVgfo4491znNMmthqGimVI7TFV706AvVJGqoIyuiFZRE5qx5MsOlIXiFwA3ue1Lo
kiFq5c6ImvS0R9LGu1Xcr0REYN53/bBVgGzJovEn7IIrHChYow7TkTLf/LsnjL3m
rmkDRgzA0C5i6fXgKkJdBhvvA521Yf75YP9n+819NUTZbtGIxRnP07pMS9RP4TjS
ZSd9an5yc7IpnL0gE4Pmnvf8LM86WTt9hZWKrE2LeQPEFgFl/Eq5NH60Zd4utxfi
qM2FH7aNsEukoAvA2v3All1wsM2kn4fMa89Hwui9h4xMy5tU"  > /docker/mongo-cluster/shard2-server1/conf/mongo.key

#处理权限为400

chmod 400 /docker/mongo-cluster/shard2-server1/conf/mongo.key

#复制
cp /docker/mongo-cluster/shard2-server1/conf/mongo.key /docker/mongo-cluster/shard2-server2/conf/mongo.key

cp /docker/mongo-cluster/shard2-server1/conf/mongo.key /docker/mongo-cluster/shard2-server3/conf/mongo.key
```

运行shard2分片组

```bash
docker run --name shard2-server1 -d \
--net=host \
--privileged=true \
-v /docker/mongo-cluster/shard2-server1/conf:/data/configdb \
-v /docker/mongo-cluster/shard2-server1/data:/data/db \
docker.io/mongo:latest mongod -f /data/configdb/mongo.conf

docker run --name shard2-server2 -d \
--net=host \
--privileged=true \
-v /docker/mongo-cluster/shard2-server2/conf:/data/configdb \
-v /docker/mongo-cluster/shard2-server2/data:/data/db \
docker.io/mongo:latest mongod -f /data/configdb/mongo.conf

docker run --name shard2-server3 -d \
--net=host \
--privileged=true \
-v /docker/mongo-cluster/shard2-server3/conf:/data/configdb \
-v /docker/mongo-cluster/shard2-server3/data:/data/db \
docker.io/mongo:latest mongod -f /data/configdb/mongo.conf
```

##### 初始化shard2分片组

并且制定第三个副本集为仲裁节点

```nginx
 docker exec  -it shard2-server1 bash
 mongo -port 20034
 
#进行副本集配置
 rs.initiate(
{
_id : "shard2",
members: [
{ _id : 0, host : "114.67.80.169:20034" },
{ _id : 1, host : "114.67.80.169:20035" },
{ _id : 2, host : "114.67.80.169:20036",arbiterOnly:true }
]
}
);
```

返回ok后创建用户

```reasonml
use admin
db.createUser({user:"root",pwd:"root",roles:[{role:'root',db:'admin'}]})
```

然后退出，分片组2搭建完成

##### 搭建shard3分片组

在同一台服务器上初始化一组分片

创建挂载文件

```bash
mkdir -p /docker/mongo-cluster/shard3-server1/{data,conf}
mkdir -p /docker/mongo-cluster/shard3-server2/{data,conf}
mkdir -p /docker/mongo-cluster/shard3-server3/{data,conf}
```

配置配置文件

```bash
echo "
# 日志文件
#systemLog:
#  destination: file
#  logAppend: true
#  path: /var/log/mongodb/data0802.log

#  网络设置
net:
  port: 20037  #端口号
#  bindIp: 127.0.0.1    #绑定ip
replication:
  replSetName: shard3
sharding:
  clusterRole: shardsvr
security:
  authorization: enabled #是否开启认证
  keyFile: /data/configdb/mongo.key #keyFile路径 "  > /docker/mongo-cluster/shard3-server1/conf/mongo.conf
------------------------------------------------------------------------------
echo "
# 日志文件
#systemLog:
#  destination: file
#  logAppend: true
#  path: /var/log/mongodb/data0802.log

#  网络设置
net:
  port: 20038  #端口号
#  bindIp: 127.0.0.1    #绑定ip
replication:
  replSetName: shard3
sharding:
  clusterRole: shardsvr
security:
  authorization: enabled #是否开启认证
  keyFile: /data/configdb/mongo.key #keyFile路径 "  > /docker/mongo-cluster/shard3-server2/conf/mongo.conf
------------------------------------------------------------------------------
echo "
# 日志文件
#systemLog:
#  destination: file
#  logAppend: true
#  path: /var/log/mongodb/data0802.log

#  网络设置
net:
  port: 20039  #端口号
#  bindIp: 127.0.0.1    #绑定ip
replication:
  replSetName: shard3
sharding:
  clusterRole: shardsvr
security:
  authorization: enabled #是否开启认证
  keyFile: /data/configdb/mongo.key #keyFile路径 "  > /docker/mongo-cluster/shard3-server3/conf/mongo.conf
```

创建keyfile

```bash
echo "tsUtJb3TeueNR8Mehr7ZLmZx82qfuCQ7LfLjUvQA7hNfWSomyNDISXDiSTJQEVym
OhXXzwB+0iv+czxi4qe9tAP8fMDuXpieZreysg4gxZ1VoFC1q39IrUDAEpCikSKS
abGl8RTEOM/GzVM8BATjaGHuBIi2osBAPg2Hzi+/u9ORbb4I4jzvgStcPcozRgOZ
5kPvXBybanV8MhLA6MfG1rcUiTkGoKb65YuWIfPuuF7PTWZe4VcF+iU6jgw73juZ
pbcZR5oTKvOWz89KCRTmQqHRexmJyn+NJcIGHFS/sZSJXE8LFPBZ+XLGYrtmDqo0
9tA1x8R+u32OJ7iOAU1mFkCHe2Uoph6aeVx/jZx1FgFjW0afT4ou2w7QHsdF0WRn
nskJ1FCA8NKzhYYgv/YrpyAChhTgd//gbWr028qz1W1POpBkj4muKUk7OTHRV6bs
qr2C73bqcZ1n2s60k6WbRUd6LP6POHR93wvi5EaXyorSMBIGiSD1Kyr/iqO7gD4C
GN8iA3MqF+fW5nKn1yBNEfPGoFk+p0EaxIAhfLEpzSRb3Wt5XLOWP7CBGuTo7KST
Y5HAcblqN7TByQhLdH5MZJ4FhfTZ0yNKTOVQdZUYRb5GGgS0GZfUk4bndLTkHrJd
tcR4WreHpz7ccncE5Vt8TGglrEx0noFVBqLqTdrqFUFpvWoukw/eViacLlBHKOxB
QVgfo4491znNMmthqGimVI7TFV706AvVJGqoIyuiFZRE5qx5MsOlIXiFwA3ue1Lo
kiFq5c6ImvS0R9LGu1Xcr0REYN53/bBVgGzJovEn7IIrHChYow7TkTLf/LsnjL3m
rmkDRgzA0C5i6fXgKkJdBhvvA521Yf75YP9n+819NUTZbtGIxRnP07pMS9RP4TjS
ZSd9an5yc7IpnL0gE4Pmnvf8LM86WTt9hZWKrE2LeQPEFgFl/Eq5NH60Zd4utxfi
qM2FH7aNsEukoAvA2v3All1wsM2kn4fMa89Hwui9h4xMy5tU"  > /docker/mongo-cluster/shard3-server1/conf/mongo.key

#处理权限为400

chmod 400 /docker/mongo-cluster/shard3-server1/conf/mongo.key

#复制
cp /docker/mongo-cluster/shard3-server1/conf/mongo.key /docker/mongo-cluster/shard3-server2/conf/mongo.key

cp /docker/mongo-cluster/shard3-server1/conf/mongo.key /docker/mongo-cluster/shard3-server3/conf/mongo.key
```

运行shard3分片组

```bash
docker run --name shard3-server1 -d \
--net=host \
--privileged=true \
-v /docker/mongo-cluster/shard3-server1/conf:/data/configdb \
-v /docker/mongo-cluster/shard3-server1/data:/data/db \
docker.io/mongo:latest mongod -f /data/configdb/mongo.conf

docker run --name shard3-server2 -d \
--net=host \
--privileged=true \
-v /docker/mongo-cluster/shard3-server2/conf:/data/configdb \
-v /docker/mongo-cluster/shard3-server2/data:/data/db \
docker.io/mongo:latest mongod -f /data/configdb/mongo.conf

docker run --name shard3-server3 -d \
--net=host \
--privileged=true \
-v /docker/mongo-cluster/shard3-server3/conf:/data/configdb \
-v /docker/mongo-cluster/shard3-server3/data:/data/db \
docker.io/mongo:latest mongod -f /data/configdb/mongo.conf
```

##### 初始化shard3分片组

并且制定第三个副本集为仲裁节点

```nginx
 docker exec  -it shard3-server1 bash
 mongo -port 20037
 
#进行副本集配置
 rs.initiate(
{
_id : "shard3",
members: [
{ _id : 0, host : "182.61.2.16:20037" },
{ _id : 1, host : "182.61.2.16:20038" },
{ _id : 2, host : "182.61.2.16:20039",arbiterOnly:true }
]
}
);
```

返回ok后创建用户

```bash
use admin
# 创建用户
db.createUser({user:"root",pwd:"root",roles:[{role:'root',db:'admin'}]})
```

然后退出，分片组3搭建完成

#### 搭建Mongos

##### 搭建Mongos1

创建配置文件

```awk
mkdir -p /docker/mongo-cluster/mongos1/{data,conf}
```

填入配置文件,这里我们删除了认证的信息，因为mongos是不能设置认证的，他也是用的前面使用的密码即可，如configserver的密码

```bash
echo "net:
  port: 20021  #端口号
sharding:
  configDB: configsvr/114.67.80.169:20011,182.61.2.16:20012,106.12.113.62:20013
security:
  keyFile: /data/configdb/mongo.key #keyFile路径
"  > /docker/mongo-cluster/mongos1/conf/mongo.conf
```

创建keyfile

```bash
echo "tsUtJb3TeueNR8Mehr7ZLmZx82qfuCQ7LfLjUvQA7hNfWSomyNDISXDiSTJQEVym
OhXXzwB+0iv+czxi4qe9tAP8fMDuXpieZreysg4gxZ1VoFC1q39IrUDAEpCikSKS
abGl8RTEOM/GzVM8BATjaGHuBIi2osBAPg2Hzi+/u9ORbb4I4jzvgStcPcozRgOZ
5kPvXBybanV8MhLA6MfG1rcUiTkGoKb65YuWIfPuuF7PTWZe4VcF+iU6jgw73juZ
pbcZR5oTKvOWz89KCRTmQqHRexmJyn+NJcIGHFS/sZSJXE8LFPBZ+XLGYrtmDqo0
9tA1x8R+u32OJ7iOAU1mFkCHe2Uoph6aeVx/jZx1FgFjW0afT4ou2w7QHsdF0WRn
nskJ1FCA8NKzhYYgv/YrpyAChhTgd//gbWr028qz1W1POpBkj4muKUk7OTHRV6bs
qr2C73bqcZ1n2s60k6WbRUd6LP6POHR93wvi5EaXyorSMBIGiSD1Kyr/iqO7gD4C
GN8iA3MqF+fW5nKn1yBNEfPGoFk+p0EaxIAhfLEpzSRb3Wt5XLOWP7CBGuTo7KST
Y5HAcblqN7TByQhLdH5MZJ4FhfTZ0yNKTOVQdZUYRb5GGgS0GZfUk4bndLTkHrJd
tcR4WreHpz7ccncE5Vt8TGglrEx0noFVBqLqTdrqFUFpvWoukw/eViacLlBHKOxB
QVgfo4491znNMmthqGimVI7TFV706AvVJGqoIyuiFZRE5qx5MsOlIXiFwA3ue1Lo
kiFq5c6ImvS0R9LGu1Xcr0REYN53/bBVgGzJovEn7IIrHChYow7TkTLf/LsnjL3m
rmkDRgzA0C5i6fXgKkJdBhvvA521Yf75YP9n+819NUTZbtGIxRnP07pMS9RP4TjS
ZSd9an5yc7IpnL0gE4Pmnvf8LM86WTt9hZWKrE2LeQPEFgFl/Eq5NH60Zd4utxfi
qM2FH7aNsEukoAvA2v3All1wsM2kn4fMa89Hwui9h4xMy5tU"  > /docker/mongo-cluster/mongos1/conf/mongo.key

#处理权限为400

chmod 400 /docker/mongo-cluster/mongos1/conf/mongo.key
```

运行mongos1

```gradle
docker run --name mongos1 -d \
--net=host \
--privileged=true \
--entrypoint "mongos" \
-v /docker/mongo-cluster/mongos1/conf:/data/configdb \
-v /docker/mongo-cluster/mongos1/data:/data/db \
docker.io/mongo:latest -f /data/configdb/mongo.conf --bind_ip_all
```

##### 搭建Mongos2

创建配置文件

```awk
mkdir -p /docker/mongo-cluster/mongos2/{data,conf}
```

填入配置文件,这里我们删除了认证的信息，因为mongos是不能设置认证的，他也是用的前面使用的密码即可，如configserver的密码

```bash
echo "net:
  port: 20022  #端口号
sharding:
  configDB: configsvr/114.67.80.169:20011,182.61.2.16:20012,106.12.113.62:20013
security:
  keyFile: /data/configdb/mongo.key #keyFile路径
"  > /docker/mongo-cluster/mongos2/conf/mongo.conf
```

创建keyfile

```bash
echo "tsUtJb3TeueNR8Mehr7ZLmZx82qfuCQ7LfLjUvQA7hNfWSomyNDISXDiSTJQEVym
OhXXzwB+0iv+czxi4qe9tAP8fMDuXpieZreysg4gxZ1VoFC1q39IrUDAEpCikSKS
abGl8RTEOM/GzVM8BATjaGHuBIi2osBAPg2Hzi+/u9ORbb4I4jzvgStcPcozRgOZ
5kPvXBybanV8MhLA6MfG1rcUiTkGoKb65YuWIfPuuF7PTWZe4VcF+iU6jgw73juZ
pbcZR5oTKvOWz89KCRTmQqHRexmJyn+NJcIGHFS/sZSJXE8LFPBZ+XLGYrtmDqo0
9tA1x8R+u32OJ7iOAU1mFkCHe2Uoph6aeVx/jZx1FgFjW0afT4ou2w7QHsdF0WRn
nskJ1FCA8NKzhYYgv/YrpyAChhTgd//gbWr028qz1W1POpBkj4muKUk7OTHRV6bs
qr2C73bqcZ1n2s60k6WbRUd6LP6POHR93wvi5EaXyorSMBIGiSD1Kyr/iqO7gD4C
GN8iA3MqF+fW5nKn1yBNEfPGoFk+p0EaxIAhfLEpzSRb3Wt5XLOWP7CBGuTo7KST
Y5HAcblqN7TByQhLdH5MZJ4FhfTZ0yNKTOVQdZUYRb5GGgS0GZfUk4bndLTkHrJd
tcR4WreHpz7ccncE5Vt8TGglrEx0noFVBqLqTdrqFUFpvWoukw/eViacLlBHKOxB
QVgfo4491znNMmthqGimVI7TFV706AvVJGqoIyuiFZRE5qx5MsOlIXiFwA3ue1Lo
kiFq5c6ImvS0R9LGu1Xcr0REYN53/bBVgGzJovEn7IIrHChYow7TkTLf/LsnjL3m
rmkDRgzA0C5i6fXgKkJdBhvvA521Yf75YP9n+819NUTZbtGIxRnP07pMS9RP4TjS
ZSd9an5yc7IpnL0gE4Pmnvf8LM86WTt9hZWKrE2LeQPEFgFl/Eq5NH60Zd4utxfi
qM2FH7aNsEukoAvA2v3All1wsM2kn4fMa89Hwui9h4xMy5tU"  > /docker/mongo-cluster/mongos2/conf/mongo.key

#处理权限为400

chmod 400 /docker/mongo-cluster/mongos2/conf/mongo.key
```

运行mongos2

```gradle
docker run --name mongos2 -d \
--net=host \
--privileged=true \
--entrypoint "mongos" \
-v /docker/mongo-cluster/mongos2/conf:/data/configdb \
-v /docker/mongo-cluster/mongos2/data:/data/db \
docker.io/mongo:latest -f /data/configdb/mongo.conf  --bind_ip_all
```

##### 搭建Mongos3

创建配置文件

```awk
mkdir -p /docker/mongo-cluster/mongos3/{data,conf}
```

填入配置文件,这里我们删除了认证的信息，因为mongos是不能设置认证的，他也是用的前面使用的密码即可，如configserver的密码

```bash
echo "net:
  port: 20023  #端口号
sharding:
  configDB: configsvr/114.67.80.169:20011,182.61.2.16:20012,106.12.113.62:20013
security:
  keyFile: /data/configdb/mongo.key #keyFile路径
"  > /docker/mongo-cluster/mongos3/conf/mongo.conf
```

创建keyfile

```bash
echo "tsUtJb3TeueNR8Mehr7ZLmZx82qfuCQ7LfLjUvQA7hNfWSomyNDISXDiSTJQEVym
OhXXzwB+0iv+czxi4qe9tAP8fMDuXpieZreysg4gxZ1VoFC1q39IrUDAEpCikSKS
abGl8RTEOM/GzVM8BATjaGHuBIi2osBAPg2Hzi+/u9ORbb4I4jzvgStcPcozRgOZ
5kPvXBybanV8MhLA6MfG1rcUiTkGoKb65YuWIfPuuF7PTWZe4VcF+iU6jgw73juZ
pbcZR5oTKvOWz89KCRTmQqHRexmJyn+NJcIGHFS/sZSJXE8LFPBZ+XLGYrtmDqo0
9tA1x8R+u32OJ7iOAU1mFkCHe2Uoph6aeVx/jZx1FgFjW0afT4ou2w7QHsdF0WRn
nskJ1FCA8NKzhYYgv/YrpyAChhTgd//gbWr028qz1W1POpBkj4muKUk7OTHRV6bs
qr2C73bqcZ1n2s60k6WbRUd6LP6POHR93wvi5EaXyorSMBIGiSD1Kyr/iqO7gD4C
GN8iA3MqF+fW5nKn1yBNEfPGoFk+p0EaxIAhfLEpzSRb3Wt5XLOWP7CBGuTo7KST
Y5HAcblqN7TByQhLdH5MZJ4FhfTZ0yNKTOVQdZUYRb5GGgS0GZfUk4bndLTkHrJd
tcR4WreHpz7ccncE5Vt8TGglrEx0noFVBqLqTdrqFUFpvWoukw/eViacLlBHKOxB
QVgfo4491znNMmthqGimVI7TFV706AvVJGqoIyuiFZRE5qx5MsOlIXiFwA3ue1Lo
kiFq5c6ImvS0R9LGu1Xcr0REYN53/bBVgGzJovEn7IIrHChYow7TkTLf/LsnjL3m
rmkDRgzA0C5i6fXgKkJdBhvvA521Yf75YP9n+819NUTZbtGIxRnP07pMS9RP4TjS
ZSd9an5yc7IpnL0gE4Pmnvf8LM86WTt9hZWKrE2LeQPEFgFl/Eq5NH60Zd4utxfi
qM2FH7aNsEukoAvA2v3All1wsM2kn4fMa89Hwui9h4xMy5tU"  > /docker/mongo-cluster/mongos3/conf/mongo.key

#处理权限为400

chmod 400 /docker/mongo-cluster/mongos3/conf/mongo.key
```

运行mongos3

```gradle
docker run --name mongos3 -d \
--net=host \
--privileged=true \
--entrypoint "mongos" \
-v /docker/mongo-cluster/mongos3/conf:/data/configdb \
-v /docker/mongo-cluster/mongos3/data:/data/db \
docker.io/mongo:latest -f /data/configdb/mongo.conf --bind_ip_all
```

##### 配置所有mongos

进入第一台mongos

```apache
docker exec -it mongos1 bash
mongo -port 20021
```

先登录（使用前面设置的root用户密码）

```stata
use admin;
db.auth("root","root");
```

进行配置分片信息

```dns
sh.addShard("shard1/114.67.80.169:20031,114.67.80.169:20032,114.67.80.169:20033")
sh.addShard("shard2/114.67.80.169:20034,114.67.80.169:20035,114.67.80.169:20036")
sh.addShard("shard3/182.61.2.16:20037,182.61.2.16:20038,182.61.2.16:20039")
```

全部返回ok则成功

去其他两台mongos执行

mongos2

```dns
docker exec -it mongos2 bash
mongo -port 20022

use admin;
db.auth("root","root");

sh.addShard("shard1/114.67.80.169:20031,114.67.80.169:20032,114.67.80.169:20033")
sh.addShard("shard2/114.67.80.169:20034,114.67.80.169:20035,114.67.80.169:20036")
sh.addShard("shard3/182.61.2.16:20037,182.61.2.16:20038,182.61.2.16:20039")
```

mongos3

```dns
docker exec -it mongos3 bash
mongo -port 20023

use admin;
db.auth("root","root");

sh.addShard("shard1/114.67.80.169:20031,114.67.80.169:20032,114.67.80.169:20033")
sh.addShard("shard2/114.67.80.169:20034,114.67.80.169:20035,114.67.80.169:20036")
sh.addShard("shard3/182.61.2.16:20037,182.61.2.16:20038,182.61.2.16:20039")
```

#### 功能测试

##### 数据库分片

```stata
sh.enableSharding("test")

对test库的test集合的_id进行哈希分片
sh.shardCollection("test.test", {"_id": "hashed" })
```

创建用户

```php
use admin;
db.auth("root","root");
use test;
db.createUser({user:"kang",pwd:"kang",roles:[{role:'dbOwner',db:'test'}]})
```

插入数据

```stata
use test
for (i = 1; i <= 300; i=i+1){db.test.insert({'name': "bigkang"})}
```

## 配置文件

### ConfigServer配置

openssl rand -base64 756 > mongo.key

```dts
# 日志文件
#systemLog:
#  destination: file
#  logAppend: true
#  path: /var/log/mongodb/data0802.log

#  网络设置
net:
  port: 27018  #端口号
#  bindIp: 127.0.0.1    #绑定ip

security:
  authorization: enabled #是否开启认证
  keyFile: /data/configdb/mongo.key #keyFile路径
```

## 环境清理

清空server1两个分片数据

```apache
docker stop mongo-server1-shard{1,2}
docker rm mongo-server1-shard{1,2}

rm -rf /docker/mongo-cluster/mongo-server1-shard{1,2}
```

清空server2两个分片数据

```apache
docker stop mongo-server2-shard{1,2}
docker rm mongo-server2-shard{1,2}

rm -rf /docker/mongo-cluster/mongo-server2-shard{1,2}
docker ps -a| grep mongo | grep -v grep| awk '{print "docker stop "$1}'|sh
docker ps -a| grep mongo | grep -v grep| awk '{print "docker rm "$1}'|sh
```