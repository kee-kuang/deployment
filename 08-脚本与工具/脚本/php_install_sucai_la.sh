#!/bin/bash

# for i in {10..15}; do
#   ansible work$i -m script -a "/root/install.sh" -i hosts.ini
# done
#for i in {01..09}; do ssh-copy-id -i ~/.ssh/id_rsa.pub work$i; done
#

# 设置模块开关
#false
INSTALL_YUM_REPO=false
INSTALL_DEPENDENCIES=true
INSTALL_LIBZIP=true
INSTALL_PHP=true
INSTALL_COMPOSER=true
CLONE_PROJECT=false

# 更新 YUM 源
if $INSTALL_YUM_REPO; then
  echo "==> 更新 YUM 源..."
  curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
  curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
  yum makecache -y
  yum repolist
fi

# 安装依赖
if $INSTALL_DEPENDENCIES; then
  echo "==> 安装依赖..."
  yum -y install epel-release
  yum install -y libxml2-d evel sqlite-devel oniguruma oniguruma-devel libxml2 libxml2-devel \
      bzip2 bzip2-devel libcurl libjpeg libjpeg-devel zstd libzstd-devel curl libcurl-devel \
      libpng libpng-devel libffi-devel libwebp-devel openssl-devel gcc make autoconf glibc-devel git supervisor
fi

# 升级并安装 libzip
if $INSTALL_LIBZIP; then
  echo "==> 安装 libzip..."
  rpm -qa | grep libzip*
  yum remove -y libzip-devel libzip
  wget https://keekuang-pubilc.oss-cn-guangzhou.aliyuncs.com/libzip-1.2.0.tar.gz -O /tmp/libzip-1.2.0.tar.gz
  cd /tmp
  tar -zxvf libzip-1.2.0.tar.gz && cd libzip-1.2.0
  ./configure
  make && make install
  echo 'export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig/"' >> /etc/profile
  source /etc/profile
fi

# 安装 PHP 相关依赖
if $INSTALL_PHP; then
  echo "==> 安装 PHP..."
  yum install -y https://mirrors.aliyun.com/remi/enterprise/remi-release-7.rpm
  yum -y install yum-utils
  yum install -y epel-release
  yum install -y php82 php82-php-devel php82-php-fpm php82-php-mbstring php82-php-memcache \
      php82-php-memcached php82-php-redis php82-php-mysqlnd php82-php-pdo php82-php-bcmath \
      php82-php-xml php82-php-gd php82-php-gmp php82-php-igbinary php82-php-imagick php82-php-mcrypt \
      php82-php-pdo_mysql php82-php-posix php82-php-simplexml php82-php-opcache php82-php-xsl \
      php82-php-xmlwriter php82-php-xmlreader php82-php-swoole php82-php-zip php82-php-phalcon \
      php82-php-yaml php82-php-yar php82-php-yaf php82-php-uuid php82*-mysql* php82-php-sockets
  ln -sf /opt/remi/php82/root/usr/bin/php /usr/bin/php
  systemctl enable --now php82-php-fpm
fi

# 安装 Composer
if $INSTALL_COMPOSER; then
  echo "==> 安装 Composer..."
  cd /opt
  curl -sS https://getcomposer.org/installer -o composer-setup.php
  EXPECTED_CHECKSUM="$(curl -sS https://composer.github.io/installer.sig)"
  ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"
  if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
    echo "安装脚本的哈希校验失败，请检查安装源的安全性。"
    rm composer-setup.php
    exit 1
  fi
  php composer-setup.php --install-dir=/usr/local/bin --filename=composer
  ln -sf /usr/local/bin/composer /usr/sbin/composer
  composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/
fi

# 拉取项目代码并设置权限
if $CLONE_PROJECT; then
  echo "==> 拉取项目代码并设置权限..."
  mkdir -p /www/yuetougz.com/sucai
  cd /www/yuetougz.com/sucai/
  git clone http://kuangzhuoqi:Kzq010524%40@gitlab.yuetougz.com:5006/sucai/sucai-hw-cms-backend.git
  cd /www/yuetougz.com/sucai/sucai-hw-cms-backend
  setfacl -R -d -m g::rwx storage
  setfacl -R -d -m u::rwx storage
  setfacl -R -d -m o::rwx storage
  chmod -R 777 storage
  composer install
fi

echo "==> 所有选定的模块已执行完成！"