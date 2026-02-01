#  VPN 部署 (WireGuard + WG-Easy)

## 1. 方案简介
本方案基于 **Ubuntu 22.04**，利用 Docker 部署带 Web 管理界面的 **WG-Easy**。
---

## 2. 宿主机基础准备

```bash
# 1. 更新系统包
sudo apt update && sudo apt upgrade -y

# 2. 开启 IP 转发 (允许流量跨网卡转发)
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# 3. 安装 Docker
sudo apt install -y docker.io docker-compose
sudo systemctl enable --now docker

# 4. 加载 WireGuard 内核模块
sudo modprobe wireguard
lsmod | grep wireguard
```

## 3. 部署 WG-Easy (Docker Compose)

创建工作目录：

```
mkdir ~/wireguard && cd ~/wireguard
```

创建配置文件(注意: **WG-Easy 的新版本（v14 及以后）出于安全考虑，禁止在配置文件中直接使用明文密码（`PASSWORD` 变量）**，强制要求使用 **Bcrypt 哈希值**（`PASSWORD_HASH`）：

```bash
vim docker-compose.yml
services:
  wg-easy:
    image: registry.cn-guangzhou.aliyuncs.com/keee/wg-easy:latest #个人仓库  原仓库为ghcr.io/wg-easy/wg-easy 推送时间为2026.1.20
    container_name: wg-easy
    volumes:
      - .:/etc/wireguard
    ports:
      - "51820:51820/udp"
      - "51821:51821/tcp"
    environment:
      # 修改为公司出口路由器的公网固定 IP 或 DDNS 域名
      WG_HOST: '183.6.106.208'
      # 管理后台的登陆密码 本次密码为: MZlC7lLOF5plqKJQ 通过node -e "console.log(require('bcryptjs').hashSync('MZlC7lLOF5plqKJQ', 12))" 生成
      PASSWORD_HASH: '$$2b$$12$$g803rzigaGIXLHT9ATk7IOnEmmp8UPIONXJq4OIY3CmCSU5Vt.R1G' #坑点: docker-cmopose 在解析yaml 之前会先做一次 环境变量转换 在任何的$xxx 都会当成环境变量引用,哪怕用单引号也没用,因为是变量转变是在yaml之前解析的,正确方式应该是将$ 改成$$
      WG_DEFAULT_DNS: '223.5.5.5,114.114.114.114'
      # 重要：设置允许访问的网段(注意不要有空格)
      # 10.8.0.0/24 是 VPN 自己的网段
      # 192.168.100.0/24 为公司真实的内网 IP 段
      WG_ALLOWED_IPS: '10.8.0.0/24,192.168.100.0/24'
      WG_PORT: 51820
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    sysctls:
      net.ipv4.conf.all.src_valid_mark: 1
      net.ipv4.ip_forward: 1
```

**一键启动：**

```
sudo docker compose up -d
```

## 4. 网络架构优化 (内网穿透)

执行以下命令，确保员工连上 VPN 后能访问公司内网其他服务器：

```
# 配置流量伪装 (NAT)
sudo iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j MASQUERADE

# 持久化防火墙规则
sudo apt install -y iptables-persistent
sudo netfilter-persistent save
```

### 5. 快速排错与日常维护

- ```
  # 查看实时连接状态
  sudo docker exec -it wg-easy wg show (能看到哪个用户正在消耗流量)
  # 查看容器日志sudo docker compose logs -f
  # 客户端连接正常但无法上网/内网
  检查 sysctl net.ipv4.ip_forward 是否为 1
  # 端口连通性自测（在外部机器测试 UDP 是否通畅）
   nc -z -v -u 公网地址 51820
  ```

  