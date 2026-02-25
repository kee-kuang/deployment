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
