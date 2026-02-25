#!/bin/bash

# =================================================================
# 腾讯云 GooseFS-Lite 一键部署脚本 (单机版)
# =================================================================
# 功能：安装依赖 -> 安装GooseFS -> 安装JDK -> 配置密钥 -> 设置开机启动
# 路径：安装在 /opt/goosefs-lite-1.0.11
# =================================================================

# ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ 请在此处修改配置 ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓

# 1. COS 访问密钥 (必填)
COS_SECRET_ID="YOUR_SECRET_ID_HERE"
COS_SECRET_KEY="YOUR_SECRET_KEY_HERE"
COS_REGION="ap-guangzhou"  

# 2. 存储桶信息 (必填)
BUCKET_URI="cosn://jishubu-1392049403/"

# 3. 本地挂载点
MOUNT_POINT="/cos"

# 4. Java 内存配置 (建议配置为物理内存的 50% 以下)
# 示例: 8G机器配 "-Xms2G -Xmx4G"
JAVA_OPTS="-Xms2G -Xmx4G -XX:MaxDirectMemorySize=1G -XX:+UseG1GC -XX:G1HeapRegionSize=32m"

# ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑ 配置结束，以下无需修改 ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

# 固定的下载地址和版本
GOOSEFS_VERSION="1.0.11"
INSTALL_DIR="/opt/goosefs-lite-${GOOSEFS_VERSION}"
INSTALL_SCRIPT_URL="https://downloads.tencentgoosefs.cn/goosefs-lite/install.sh"
JDK_URL="https://github.com/Tencent/TencentKona-11/releases/download/kona11.0.22/TencentKona-11.0.22.b1-jdk_linux-x86_64.tar.gz"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO] $1${NC}"; }
log_err() { echo -e "${RED}[ERROR] $1${NC}"; }

# 检查是否为 root
if [ "$EUID" -ne 0 ]; then
  log_err "请使用 root 权限运行此脚本 (sudo ./deploy_goosefs.sh)"
  exit 1
fi

# 检查配置是否已修改
if [[ "$COS_SECRET_ID" == "AKIDxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" ]]; then
    log_err "请先编辑脚本文件，填入真实的 COS_SECRET_ID 和 COS_SECRET_KEY！"
    exit 1
fi

# =================================================================
# 1. 安装系统依赖
# =================================================================
log_info "步骤 1/5: 安装系统依赖..."

if command -v apt-get &> /dev/null; then
    apt-get update && apt-get install -y libfuse-dev curl
elif command -v yum &> /dev/null; then
    yum install -y fuse-devel curl
else
    log_err "未检测到 apt 或 yum，请手动安装 fuse 开发包"
    exit 1
fi

# =================================================================
# 2. 安装 GooseFS-Lite
# =================================================================
log_info "步骤 2/5: 安装 GooseFS-Lite (${GOOSEFS_VERSION})..."

if [ -d "$INSTALL_DIR" ]; then
    log_info "目录 $INSTALL_DIR 已存在，跳过下载安装。"
else
    # 切换到 /opt 目录执行安装，确保解压在 /opt 下
    cd /opt
    curl -fssL "$INSTALL_SCRIPT_URL" | sh
    
    if [ ! -d "$INSTALL_DIR" ]; then
        log_err "安装失败：未找到目录 $INSTALL_DIR"
        exit 1
    fi
fi

# =================================================================
# 3. 安装 KonaJDK 11
# =================================================================
log_info "步骤 3/5: 安装 KonaJDK 11..."

if [ -f "/usr/local/konajdk11/bin/java" ]; then
    log_info "JDK 已存在 (/usr/local/konajdk11)，跳过安装。"
else
    cd "$INSTALL_DIR"
    # 执行内置的 install-jdk.sh
    # 注意：如果 GitHub 连接慢，可能需要等待较久
    bash bin/install-jdk.sh "$JDK_URL"
    
    if [ ! -f "/usr/local/konajdk11/bin/java" ]; then
        log_err "JDK 安装失败！如果是网络原因，请手动下载 JDK 包放到 $INSTALL_DIR 目录下再重试。"
        exit 1
    fi
fi

# =================================================================
# 4. 修改配置文件
# =================================================================
log_info "步骤 4/5: 配置 core-site.xml..."

CORE_SITE_XML="${INSTALL_DIR}/conf/core-site.xml"

# 使用 sed 替换配置
sed -i "/<name>fs.cosn.userinfo.secretId<\/name>/{N;s/<value>[^<]*<\/value>/<value>${COS_SECRET_ID}<\/value>/}" "$CORE_SITE_XML"
sed -i "/<name>fs.cosn.userinfo.secretKey<\/name>/{N;s/<value>[^<]*<\/value>/<value>${COS_SECRET_KEY}<\/value>/}" "$CORE_SITE_XML"
sed -i "/<name>fs.cosn.bucket.region<\/name>/{N;s/<value>[^<]*<\/value>/<value>${COS_REGION}<\/value>/}" "$CORE_SITE_XML"

log_info "配置已更新。"

# =================================================================
# 5. 配置 Systemd 服务并启动
# =================================================================
log_info "步骤 5/5: 配置 Systemd 服务..."

# 创建挂载点
if [ ! -d "$MOUNT_POINT" ]; then
    mkdir -p "$MOUNT_POINT"
fi

SERVICE_FILE="/usr/lib/systemd/system/goosefs-lite.service"

cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=The Tencent Cloud GooseFS Lite for COS
Requires=network-online.target
After=network-online.target

[Service]
Type=forking
User=root
Environment="JAVA_OPTS=${JAVA_OPTS}"
ExecStart=${INSTALL_DIR}/bin/goosefs-lite mount ${MOUNT_POINT} ${BUCKET_URI}
ExecStop=${INSTALL_DIR}/bin/goosefs-lite umount ${MOUNT_POINT}
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# 重载并启动
systemctl daemon-reload
systemctl enable goosefs-lite

log_info "正在启动服务 (这可能需要几秒钟)..."
systemctl restart goosefs-lite

# 检查状态
sleep 3
if systemctl is-active --quiet goosefs-lite; then
    log_info "=========================================="
    log_info "✅ 部署成功！"
    log_info "挂载点: ${MOUNT_POINT}"
    log_info "进程状态:"
    ps -ef | grep goosefs-lite | grep -v grep
    echo "------------------------------------------"
    ls -ld "$MOUNT_POINT"
    log_info "=========================================="
else
    log_err "❌ 服务启动失败，请检查日志："
    log_err "命令: systemctl status goosefs-lite"
    log_err "命令: journalctl -xeu goosefs-lite"
    
    # 尝试手动运行一次看报错
    echo "尝试手动运行以显示报错信息："
    ${INSTALL_DIR}/bin/goosefs-lite mount ${MOUNT_POINT} ${BUCKET_URI}
fi