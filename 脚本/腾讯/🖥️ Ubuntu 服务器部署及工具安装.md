# 🖥️ Ubuntu 服务器部署及工具安装

------

## 目录结构与快速操作表

| 模块                        | 脚本/命令                                         | 适用机器       | 备注                        |
| --------------------------- | ------------------------------------------------- | -------------- | --------------------------- |
| NFS 挂载                    | `apt install -y nfs-common`                       | 全部           | 基础挂载工具                |
| NAS 同步                    | `rsync ...`                                       | 全部           | 可选，25号确认              |
| PHP & Composer & Supervisor | `tengxun-install.sh`                              | 全部           | PHP8.3                      |
| Swoole & Curl               | `install_swoole_with_curl.sh`                     | 全部           | PHP 扩展                    |
| FFmpeg 7.1                  | `install_ffmpeg_7.1.sh`                           | work01-work04  | 含 drawtext                 |
| Git 凭证 & 项目拉取         | `git clone ...`                                   | 全部           | sucai-cms-backend-hyperf-hw |
| Python 3.12 + pip           | `apt install -y python3-pip`                      | work01, work05 | 系统自带 Python3.12         |
| Python 3.13 + pip3.13       | `wget ... && make altinstall`                     | work01, work05 | 源码安装                    |
| Conda                       | `Miniconda3-latest-Linux-x86_64.sh`               | work01, work05 | Miniconda                   |
| Mihomo                      | `wget ... && ./mihomo -t -f config.yaml`          | work01, work05 | 配置 systemd                |
| Docker & Docker Compose     | `apt install docker-ce docker-compose-plugin`     | GPU 机器       | 可迁移数据到 /data/docker   |
| Dify 1.10.0                 | `git clone ... && docker-compose up -d`           | 全部           | 修改镜像仓库                |
| Ansible                     | `/etc/ansible/hosts` + `sshpass`                  | 控制机         | 批量管理节点                |
| ClickHouse                  | `apt install clickhouse-server clickhouse-client` | 全部           | 安装完成，未迁移            |

------

## 安装 NFS 并挂载

```bash
apt update
apt install -y nfs-common
```

------

## 同步 NAS 数据（可选）

```bash
nohup rsync -avH --numeric-ids \
  --progress \
  --partial \
  -e "ssh -T -c aes128-gcm@openssh.com -o Compression=no -o ServerAliveInterval=60" \
  /nas/ \
  root@139.199.162.107:/nas/ \
  > /var/log/rsync_nas_full.log 2>&1 &
```

------

## 部署 PHP 8.3、Composer 和 Supervisor

```bash
bash install_php.sh
#!/bin/bash
set -e

# =========================
# 模块开关
# =========================
INSTALL_DEPENDENCIES=true
INSTALL_PHP=true
INSTALL_COMPOSER=true
INSTALL_SWOOLE=true

PHP_VERSION=8.3
SWOOLE_VERSION=5.1.7

# =========================
# 安装系统依赖
# =========================
if $INSTALL_DEPENDENCIES; then
  echo "==> 安装系统依赖..."
  apt update
  apt install -y \
    software-properties-common ca-certificates lsb-release \
    apt-transport-https curl wget git unzip supervisor \
    gcc g++ make autoconf pkg-config \
    libxml2-dev libsqlite3-dev libonig-dev \
    libcurl4-openssl-dev libjpeg-dev libpng-dev \
    libwebp-dev libffi-dev libssl-dev \
    libzip-dev zlib1g-dev \
    brotli libbrotli-dev
fi

# =========================
# 安装 PHP 8.3
# =========================
if $INSTALL_PHP; then
  echo "==> 安装 PHP 8.3..."

  apt install -y gnupg

  curl -fsSL https://keyserver.ubuntu.com/pks/lookup?op=get\&search=0x4F4EA0AAE5267A6C | \
    gpg --dearmor -o /usr/share/keyrings/ondrej-php.gpg

  echo "deb [signed-by=/usr/share/keyrings/ondrej-php.gpg] https://ppa.launchpadcontent.net/ondrej/php/ubuntu $(lsb_release -sc) main" \
    > /etc/apt/sources.list.d/ondrej-php.list

  apt update

  apt install -y \
    php8.3 php8.3-cli php8.3-fpm php8.3-dev php8.3-common \
    php8.3-mbstring php8.3-bcmath php8.3-xml php8.3-curl \
    php8.3-gd php8.3-gmp php8.3-intl php8.3-zip \
    php8.3-opcache php8.3-soap php8.3-readline \
    php8.3-mysql php8.3-sqlite3 php8.3-redis \
    php8.3-imagick php8.3-yaml php8.3-uuid \
    php8.3-sockets

  update-alternatives --set php /usr/bin/php8.3
  systemctl enable php8.3-fpm
  systemctl restart php8.3-fpm
fi

# =========================
# 编译安装 Swoole 5.1.7
# =========================
if $INSTALL_SWOOLE; then
  echo "==> 编译 Swoole ${SWOOLE_VERSION}..."

  cd /usr/local/src
  wget -nc https://pecl.php.net/get/swoole-${SWOOLE_VERSION}.tgz
  tar -zxf swoole-${SWOOLE_VERSION}.tgz
  cd swoole-${SWOOLE_VERSION}

  phpize

  ./configure \
    --with-php-config=/usr/bin/php-config8.3 \
    --enable-openssl \
    --enable-sockets \
    --enable-swoole-curl

  make -j$(nproc)
  make install

  echo "extension=swoole" > /etc/php/8.3/mods-available/swoole.ini
  phpenmod swoole

  systemctl restart php8.3-fpm
fi

# =========================
# 安装 Composer
# =========================
if $INSTALL_COMPOSER; then
  echo "==> 安装 Composer..."

  cd /tmp
  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
  php composer-setup.php --install-dir=/usr/local/bin --filename=composer
  rm composer-setup.php

  composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/
fi

# =========================
# 验证 Swoole
# =========================
php --ri swoole || true

echo "==> 所有模块安装完成"

```

------

## 部署 Swoole 插件 & 更新 Curl

```bash
bash install_swoole_with_curl.sh
#!/bin/bash
set -e

echo "========== 1. 安装编译依赖 =========="

apt update
apt install -y \
  build-essential \
  autoconf \
  pkg-config \
  libssl-dev \
  libbrotli-dev \
  libnghttp2-dev \
  libidn2-dev \
  librtmp-dev \
  libpsl-dev \
  zlib1g-dev \
  ca-certificates \
  wget curl

echo "========== 2. 编译安装 curl 8.7.1 =========="

cd /usr/local/src

if [ ! -d curl-8.7.1 ]; then
  wget https://curl.se/download/curl-8.7.1.tar.gz
  tar -zxvf curl-8.7.1.tar.gz
fi

cd curl-8.7.1

./configure \
  --prefix=/usr/local/curl \
  --with-ssl \
  --with-brotli \
  --with-nghttp2

make -j$(nproc)
make install

echo "========== 3. 替换系统 curl =========="

if [ -f /usr/bin/curl ] && [ ! -f /usr/bin/curl.bak ]; then
  mv /usr/bin/curl /usr/bin/curl.bak
fi

ln -sf /usr/local/curl/bin/curl /usr/bin/curl

echo "========== 4. 设置环境变量 =========="

echo 'export LD_LIBRARY_PATH=/usr/local/curl/lib:$LD_LIBRARY_PATH' > /etc/profile.d/curl.sh
echo 'export PKG_CONFIG_PATH=/usr/local/curl/lib/pkgconfig:$PKG_CONFIG_PATH' >> /etc/profile.d/curl.sh

source /etc/profile.d/curl.sh

curl -V

echo "========== 5. 下载并编译 swoole 5.1.7 =========="

cd /usr/local/src

if [ ! -d swoole-5.1.7 ]; then
  wget https://pecl.php.net/get/swoole-5.1.7.tgz
  tar -xvf swoole-5.1.7.tgz
fi

cd swoole-5.1.7

phpize

./configure \
  --enable-openssl \
  --enable-sockets \
  --enable-swoole-curl \
  --with-php-config=$(which php-config)

make -j$(nproc)
make install

echo "========== 6. 启用 swoole 扩展 =========="

PHP_INI_DIR=$(php -r "echo PHP_CONFIG_FILE_SCAN_DIR;")
echo "extension=swoole.so" > ${PHP_INI_DIR}/20-swoole.ini

php --ri swoole

echo "========== Swoole + Curl 安装完成 =========="

```

------

## 部署 FFmpeg 7.1（含 drawtext）

```bash
bash install_ffmpeg_7.1.sh
#!/bin/bash
set -e

FFMPEG_VERSION="7.1"
PREFIX="/usr/local/ffmpeg"
SRC_DIR="/usr/local/src"

echo "======================================"
echo " FFmpeg ${FFMPEG_VERSION} 安装开始"
echo " 安装路径: ${PREFIX}"
echo "======================================"

# =========================
# 1. 安装系统依赖
# =========================
echo "==> 安装编译依赖..."
apt update
apt install -y \
  build-essential pkg-config yasm nasm \
  autoconf automake libtool cmake \
  libfreetype6-dev \
  libfontconfig1-dev \
  libharfbuzz-dev \
  libfribidi-dev \
  libx264-dev \
  libx265-dev \
  libssl-dev \
  libnuma-dev \
  ca-certificates curl wget

# =========================
# 2. 下载 FFmpeg 源码
# =========================
mkdir -p ${SRC_DIR}
cd ${SRC_DIR}

if [ ! -f ffmpeg-${FFMPEG_VERSION}.tar.gz ]; then
  echo "==> 下载 FFmpeg ${FFMPEG_VERSION}..."
  wget https://ops-kee-1392049403.cos.ap-guangzhou.myqcloud.com/ffmpeg-7.1.tar.gz
fi

rm -rf ffmpeg-${FFMPEG_VERSION}
tar -zxf ffmpeg-${FFMPEG_VERSION}.tar.gz
cd ffmpeg-${FFMPEG_VERSION}

# =========================
# 3. 配置（关键）
# =========================
echo "==> 执行 configure..."

./configure \
  --prefix=${PREFIX} \
  --enable-gpl \
  --enable-nonfree \
  --enable-openssl \
  --enable-libfreetype \
  --enable-libfontconfig \
  --enable-libharfbuzz \
  --enable-libfribidi \
  --enable-libx264 \
  --enable-libx265 \
  --disable-static \
  --enable-shared

# =========================
# 4. 强制校验 drawtext
# =========================
echo "==> 校验 drawtext 是否启用..."

if ! grep -q "CONFIG_DRAWTEXT_FILTER=yes" ffbuild/config.mak; then
  echo "❌ drawtext 未启用，终止安装"
  exit 1
fi

echo "✔ drawtext 已启用"

# =========================
# 5. 编译 & 安装
# =========================
echo "==> 编译 FFmpeg..."
make -j$(nproc)

echo "==> 安装 FFmpeg..."
make install

# =========================
# 6. 动态库加载（兜底）
# =========================
echo "==> 配置动态库路径..."
echo "${PREFIX}/lib" > /etc/ld.so.conf.d/ffmpeg.conf
ldconfig

# =========================
# 7. 统一系统入口（关键）
# =========================
echo "==> 创建系统入口..."

ln -sf ${PREFIX}/bin/ffmpeg /usr/local/bin/ffmpeg
ln -sf ${PREFIX}/bin/ffprobe /usr/local/bin/ffprobe

# =========================
# 8. 最终验证
# =========================
echo "==> 最终验证..."

which ffmpeg
ffmpeg -version
ffmpeg -filters | grep drawtext

echo "======================================"
echo " FFmpeg ${FFMPEG_VERSION} 安装完成"
echo " 直接使用命令: ffmpeg"
echo "======================================"

```

------

## Git 凭证 & 项目拉取

```bash
git config --global credential.helper store
echo "https://kuangzhuoqi:Kzq010524%40@gitlab.yuetougz.com:5006" >> ~/.git-credentials
chmod 600 ~/.git-credentials

git config --global credential.helper store && \
echo "http://kuangzhuoqi:$(python3 -c "import urllib.parse; print(urllib.parse.quote('Kzq010524@'))")@gitlab.yuetougz.com:5006" > ~/.git-credentials && \
chmod 600 ~/.git-credentials

git clone http://gitlab.yuetougz.com:5006/sucai/sucai-cms-backend-hyperf.git sucai-cms-backend-hyperf-hw
```

------

## 部署 Python

```bash
# Python 3.12 + pip
apt install -y python3-pip

# Python 3.13 + pip3.13
cd /usr/src
wget https://ops-kee-1392049403.cos.ap-guangzhou.myqcloud.com/package/Python-3.13.0.tgz
tar xzf Python-3.13.0.tgz
cd Python-3.13.0
./configure --enable-optimizations --with-ensurepip=install
make -j$(nproc)
make altinstall
python3.13 --version
pip3.13 --version
```

------

## 安装 Conda

```bash
wget https://ops-kee-1392049403.cos.ap-guangzhou.myqcloud.com/kee-pubilc/Miniconda3-latest-Linux-x86_64.sh
bash -x Miniconda3-latest-Linux-x86_64.sh
source ~/.bashrc
conda --version
```

------

## 部署 Mihomo

```bash
mkdir /etc/mihomo
cd /etc/mihomo
wget https://ops-kee-1392049403.cos.ap-guangzhou.myqcloud.com/clash/mihomo-linux-amd64-v3-v1.19.18.gz
gunzip mihomo-linux-amd64-v3-v1.19.18.gz
mv mihomo-linux-amd64-v3-v1.19.18 mihomo
chmod +x mihomo
cp mihomo /usr/local/bin
wget https://ops-kee-43.133.173.1531392049403.cos.ap-guangzhou.myqcloud.com/clash/GeoLite2-Country.mmdb
wget https://ops-kee-1392049403.cos.ap-guangzhou.myqcloud.com/clash/dler-config.yaml
mv GeoLite2-Country.mmdb country.mmdb
ln -s country.mmdb Country.mmdb
mv dler-config.yaml config.yaml
./mihomo -t -f config.yaml
```

### 配置 Systemd 服务

```ini
[Unit]
Description=mihomo Daemon, Another Clash Kernel.
After=network.target NetworkManager.service systemd-networkd.service iwd.service

[Service]
Type=simple
LimitNPROC=500
LimitNOFILE=1000000
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_RAW CAP_NET_BIND_SERVICE CAP_SYS_TIME CAP_SYS_PTRACE CAP_DAC_READ_SEARCH CAP_DAC_OVERRIDE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_RAW CAP_NET_BIND_SERVICE CAP_SYS_TIME CAP_SYS_PTRACE CAP_DAC_READ_SEARCH CAP_DAC_OVERRIDE
Restart=always
ExecStartPre=/usr/bin/sleep 1s
ExecStart=/usr/local/bin/mihomo -d /etc/mihomo
ExecReload=/bin/kill -HUP $MAINPID

[Install]
WantedBy=multi-user.target
systemctl daemon-reload
systemctl start mihomo
systemctl reload mihomo
curl -x http://127.0.0.1:7890 http://ip.sb
journalctl -u clash -f
```

------

## 部署 Docker & Docker Compose

```bash
sudo apt update
sudo apt remove docker docker-engine docker.io containerd runc -y
apt install -y ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
docker --version
docker compose version
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl status docker
```

### Docker 数据迁移

```bash
sudo systemctl stop docker
sudo systemctl stop containerd
sudo mkdir -p /data/docker
sudo chown root:root /data/docker
sudo chmod 711 /data/docker
sudo rsync -aHAXx /var/lib/docker/ /data/docker/

sudo tee /etc/docker/daemon.json <<EOF
{
  "data-root": "/data/docker"
}
EOF

sudo systemctl daemon-reload
sudo systemctl start containerd
sudo systemctl start docker
docker info | grep "Docker Root Dir"
```

------

## 部署 Dify 1.10.0

```bash
git clone http://gitlab.yuetougz.com:5006/ai/dify.git
docker-compose up -d
```

------

## 部署 Ansible

```bash
cat > /tmp/hosts.txt << 'EOF'
172.16.0.10
172.16.0.4
172.16.0.5
172.16.0.15
172.16.0.11
172.16.0.8
172.16.0.9
172.16.0.13
172.16.0.14
EOF

apt install -y sshpass
for ip in $(cat /tmp/hosts.txt); do
  echo "===== ubuntu@$ip ====="
  sshpass -p '8QyMLyhDfvZdLPnb@' ssh-copy-id \
    -o StrictHostKeyChecking=no \
    -i /root/.ssh/id_ed25519.pub \
    ubuntu@$ip
done

cat > /etc/ansible/hosts << 'EOF'
[servers]
work02        ansible_host=172.16.0.10
work05        ansible_host=172.16.0.4
work04        ansible_host=172.16.0.5
work03        ansible_host=172.16.0.15
work01        ansible_host=172.16.0.11
gpu-work01    ansible_host=172.16.0.8
master        ansible_host=172.16.0.9
slave_uat     ansible_host=172.16.0.13
clickhouse    ansible_host=172.16.0.14

[servers:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=/root/.ssh/id_ed25519
ansible_become=true
ansible_become_method=sudo
ansible_python_interpreter=/usr/bin/python3
EOF
```

------

## 部署 ClickHouse

```bash
sudo apt update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
curl -fsSL 'https://packages.clickhouse.com/rpm/lts/repodata/repomd.xml.key' | sudo gpg --dearmor -o /usr/share/keyrings/clickhouse-keyring.gpg
ARCH=$(dpkg --print-architecture)
echo "deb [signed-by=/usr/share/keyrings/clickhouse-keyring.gpg arch=${ARCH}] https://packages.clickhouse.com/deb stable main" | sudo tee /etc/apt/sources.list.d/clickhouse.list
sudo apt-get update
sudo apt-get install -y clickhouse-server clickhouse-client
sudo systemctl enable clickhouse-server
sudo systemctl start clickhouse-server
sudo systemctl status clickhouse-server
```