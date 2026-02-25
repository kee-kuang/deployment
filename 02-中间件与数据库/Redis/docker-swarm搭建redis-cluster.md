## 通过docker swarm 集群搭建 redis cluster （三主三从）

### 1. 安装 docker-ce （此文档使用离线安装）

```shell script
1. 下载地址docker 离线安装包
  https://download.docker.com/linux/static/stable/x86_64/
2. 解压压缩包并将docker 相关命令拷贝到/usr/bin底下
   cp docker/* /usr/bin/
3. 启动Docker 守护程序
    docker & 
4. 验证是否成功
    docker info 
5. 将docker 注册成系统服务 （记得kill 刚刚启动的docker服务后，再执行这一步喔）
      vi /usr/lib/systemd/system/docker.service
 [Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target
 
[Service]
Type=notify
ExecStart=/usr/bin/dockerd
ExecReload=/bin/kill -s HUP $MAINPID
LimitNOFILE=infinity
LimitNPROC=infinity
TimeoutStartSec=0
Delegate=yes
KillMode=process
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s
 
[Install]
WantedBy=multi-user.target

systemctl start docker 
systemctl enable docker 
systemctl status docker 
```

### 2. 创建 swarm 集群

```shell script
1.在其中一台机器（管理节点）上 执行初始化命令
docker swarm init --advertise-addr 10.0.0.26
# --advertise-addr参数表示其它swarm中的worker节点使用此ip地址与manager联系。
```

### 3. 加入Swarm 集群命令

```shell script
#在管理节点上输出
# 此命令是获取token 来加入节点，需保证docker 端口2375通 ，每条token时效为24小时
# 加入管理节点
  docker swarm join-token manager
# 加入工作节点
  docker swarm join-token worker 
# 查看 swarm 节点状态 (只能在管理节点上执行所有的docker swarm 相关命令)
   docker node ls 
```

### 4. 创建 网络

```shell
# 创建新的网络信息
  docker network create -d overlay --attachable middleware
# 查看是否创建成功
  docker network ls 

```

### 5. 给每个节点创建标签

```
# 创建标签
   docker node update --label-add redis=node1 worker1
   .....
# 确认标签是否创建成功
   docker node ls  | awk '{print $1}' | xargs -I {} docker node inspect {} | grep redis

```

### 6. 创建持久化目录

```
mkdir /redis-data
```

### 7. 创建redis.conf 配置文件 (根据需要修改配置)

```
   vim redis.conf
echo > EOF   
port 6379
bind 0.0.0.0
requirepass SSY@redis$
masterauth SSY@redis$
maxmemory 30gb


#rdb backup
save 300 10

#aof backup
appendonly yes
no-appendfsync-on-rewrite  yes
maxmemory-policy allkeys-lru

# cluster 
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 5000
cluster-announce-ip 10.0.0.26  ## 指定注册ip

EOF
```

### 8. 编写redis.yml 编排文件

```yaml
version: '3.8'

services:
  redis-1:
    image: registry.cn-guangzhou.aliyuncs.com/keee/redis:5.0.4-test
    networks:
      - middleware  
    volumes:
      - /redis-data:/data
      - /opt/redis.conf:/usr/local/etc/redis/redis.conf
    ports:
      - target: 6379
        published: 6379
        protocol: tcp
        mode: host
      - target: 16379
        published: 16379
        protocol: tcp
        mode: host
    deploy:
      placement:
        constraints:
          - node.labels.redis == node1

  redis-2:
    image: registry.cn-guangzhou.aliyuncs.com/keee/redis:5.0.4-test
    networks:
      - middleware  
    volumes:
      - /redis-data:/data
      - /opt/redis.conf:/usr/local/etc/redis/redis.conf
    ports:
      - target: 6379
        published: 6379
        protocol: tcp
        mode: host
      - target: 16379
        published: 16379
        protocol: tcp
        mode: host
    deploy:
      placement:
        constraints:
          - node.labels.redis == node2

  redis-3:
    image: registry.cn-guangzhou.aliyuncs.com/keee/redis:5.0.4-test
    networks:
      - middleware
    volumes:
      - /redis-data:/data
      - /opt/redis.conf:/usr/local/etc/redis/redis.conf
    ports:
      - target: 6379
        published: 6379
        protocol: tcp
        mode: host
      - target: 16379
        published: 16379
        protocol: tcp
        mode: host
    deploy:
      placement:
        constraints:
          - node.labels.redis == node3

  redis-4:
    image: registry.cn-guangzhou.aliyuncs.com/keee/redis:5.0.4-test
    networks:
      - middleware 
    volumes:
      - /redis-data:/data
      - /opt/redis.conf:/usr/local/etc/redis/redis.conf
    ports:
      - target: 6379
        published: 6379
        protocol: tcp
        mode: host
      - target: 16379
        published: 16379
        protocol: tcp
        mode: host
    deploy:
      placement:
        constraints:
          - node.labels.redis == node4

  redis-5:
    image: registry.cn-guangzhou.aliyuncs.com/keee/redis:5.0.4-test
    networks:
      - middleware 
    volumes: 
      - /redis-data:/data
      - /opt/redis.conf:/usr/local/etc/redis/redis.conf
    ports:
      - target: 6379
        published: 6379
        protocol: tcp
        mode: host
      - target: 16379
        published: 16379
        protocol: tcp
        mode: host
    deploy:
      placement:
        constraints:
          - node.labels.redis == node5

  redis-6:
    image: registry.cn-guangzhou.aliyuncs.com/keee/redis:5.0.4-test
    networks:
      - middleware 
    volumes: 
      - /redis-data:/data
      - /opt/redis.conf:/usr/local/etc/redis/redis.conf
    ports:
      - target: 6379
        published: 6379
        protocol: tcp
        mode: host
      - target: 16379
        published: 16379
        protocol: tcp
        mode: host
    deploy:
      placement:
        constraints:
          - node.labels.redis == node6
    

networks:
  middleware:
    external: true



```

### 9. 启动节点和检查节点状态

```shell
# 启动节点
   docker stack up -c redis.yml redis
# 查看节点状态
   watch docker stack ps redis 
```



### 10. 组成redis 集群 

```shell
# 执行创建redis集群命令  

# --cluster-replicas 1  指定每个节点启动一个

redis-cli --cluster create 10.0.0.26:6379 10.0.1.132:6379 10.0.1.134:6379 10.0.1.137:6379 10.0.1.139:6379  10.0.1.153:6379 -a SSY@redis$ --cluster-replicas 1

# 查看redis 集群状态
  redis-cli -a SSY@redis$ cluster info 
# 查看redis 节点
  redis-cli -a SSY@redis$ cluster nodes 

```

x
