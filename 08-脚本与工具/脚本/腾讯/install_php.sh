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
