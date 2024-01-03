## 离线安装docker 

### 1.下载Docker 二进制文件（离线安装包）

```
# 下载地址：
https://download.docker.com/linux/static/stable/x86_64/

```

### 2. 将docker 相关命令拷贝到/usr/bin 

```
# cp docker/* /usr/bin/
```

### 3. 启动Docker守护程序

```
# dockerd &
```

### 4. **验证是否安装成功，执行docker info命令，若正常打印版本信息则安装成功。**

```
# docker info
```

### 5. 将docker 注册成 系统服务（记得kill docker服务后，再执行这一步哦）

```
# vi /usr/lib/systemd/system/docker.service
# [Unit]
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

# systemctl start docker
# systemctl enable docker

```

