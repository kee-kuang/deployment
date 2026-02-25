# Teleport 混合云部署方案

## 1. 架构设计说明

- **中心节点 (Auth + Proxy)**：部署在具有公网 IP 的云服务器上（Ubuntu 24.04）。
- **连接逻辑**：采用 **反向隧道 (Reverse Tunnel)** 机制。所有云端和 CID 内网的节点均通过 **443 端口** 向中心节点发起连接。
- **优势**：
  - **稳定性**：远超 JumpServer，解决跨网段连接超时问题。
  - **安全性**：内网 CID 环境不需要开放任何入站端口。
  - **灵活性**：支持通过标签（Labels）实现类似树状目录的分组管理。

------

## 2. 云中心节点安装 (Ubuntu 24.04)

### A. 系统环境与安全组

- **推荐配置**：2 核 CPU / 4GB 内存。
- **端口开放**：在云平台安全组中开放 **TCP: 443**。

### B. 安装 Teleport 服务

Bash

```
# 1. 下载并安装 GPG 密钥
sudo curl https://apt.releases.teleport.dev/gpg \
  -o /usr/share/keyrings/teleport-archive-keyring.asc

# 2. 添加针对 Ubuntu 24.04 (Noble) 的官方仓库
echo "deb [signed-by=/usr/share/keyrings/teleport-archive-keyring.asc] \
  https://apt.releases.teleport.dev/ubuntu noble stable/v14" \
  | sudo tee /etc/apt/sources.list.d/teleport.list

# 3. 执行安装
sudo apt update
sudo apt install teleport
```

------

## 3. 核心配置与初始化

### A. 准备 SSL 证书

将你的域名证书文件存放在指定位置：

- **私钥**：`/var/lib/teleport/yuetougz.com.key`
- **证书**：`/var/lib/teleport/yuetougz.com.pem`

### B. 编辑配置文件 `/etc/teleport.yaml`

YAML

```
version: v3
teleport:
  nodename: teleport-cloud-center
  data_dir: /var/lib/teleport
  log:
    output: stderr
    severity: INFO
auth_service:
  enabled: "yes"
  cluster_name: "teleport.yuetougz.com"
  proxy_listener_mode: multiplex
ssh_service:
  enabled: "yes"
  labels:
    env: "cloud"
proxy_service:
  enabled: "yes"
  web_listen_addr: 0.0.0.0:443
  public_addr: "teleport.yuetougz.com:443"
  https_keypairs:
  - key_file: /var/lib/teleport/yuetougz.com.key
    cert_file: /var/lib/teleport/yuetougz.com.pem
```

### C. 启动与管理账号

1. **启动服务**：`sudo systemctl enable teleport --now`

2. **创建初始管理员**（触发 2FA 绑定）：

   Bash

   ```
   sudo tctl users add admin --roles=editor,access --logins=root,ubuntu,admin
   ```

   - *在浏览器打开生成的链接，使用手机验证器扫码完成初始化。*

------

## 4. 资产接入与分组管理 (类似 JumpServer)

Teleport 使用 **标签 (Labels)** 机制实现资产分类。

### A. 接入 CID 内网资产 (例如：jenkins-slave)

登录目标内网机器，执行从 Web 界面获取的脚本并**手动指定标签**：

Bash

```
sudo bash -c "$(curl -fsSL https://teleport.yuetougz.com/scripts/.../install-node.sh)" \
  --labels "env=cid,dept=ops,group=intranet"
```

### B. 接入云端资产 (例如：tx-clickhouse)

Bash

```
sudo bash -c "$(curl -fsSL https://teleport.yuetougz.com/scripts/.../install-node.sh)" \
  --labels "env=cloud,provider=tencent,group=database"
```

### C. 分组查看技巧

- **快速过滤**：在 Resources 页面点击标签（如 `env: cid`）。
- **保存查询**：点击搜索框旁的 **“五角星”** 收藏常用标签组合（如“腾讯云资产”），实现一键直达，模拟 JumpServer 文件夹效果。

------

## 5. 运维监控与安全性建议

- **2FA 强制性**：所有用户必须通过双因子验证登录，确保公网暴露下的安全性。
- **审计录像**：所有 SSH 会话会自动生成录像，建议定期清理旧数据。
- **角色限制**：针对不同部门（如 `ops` 或 `dev`），通过 Role 的 `node_labels` 属性限制其只能看到特定标签的机器。