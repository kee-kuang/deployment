#!/bin/bash
# 确保脚本以 root 权限运行
if [ "$EUID" -ne 0 ]; then
  echo "请以 root 用户运行此脚本。"
  exit 1
fi
# 定义模块函数
# 更新 CentOS 和 EPEL 源到阿里云镜像
source_setup() {
  echo "配置阿里云 CentOS 和 EPEL 源..."
  curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
  curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
  yum makecache -y
  yum repolist
}
# 安装基础依赖包
install_dependencies() {
  echo "安装 EPEL 包和系统依赖..."
  yum -y install epel-release
  yum install -y libxml2-devel sqlite-devel oniguruma oniguruma-devel libxml2 libxml2-devel \
    bzip2 bzip2-devel libcurl libjpeg libjpeg-devel zstd libzstd-devel curl libcurl-devel \
    libpng libpng-devel libffi-devel libwebp-devel openssl-devel gcc make autoconf glibc-devel git supervisor
}
# 安装 libzip 1.2.0
install_libzip() {
  echo "检查并安装 libzip 1.2.0..."
  rpm -qa | grep libzip*
  yum remove -y libzip-devel libzip
  wget https://jln-yuetougz.oss-cn-guangzhou.aliyuncs.com/kee-pubilc/libzip-1.2.0.tar.gz -O /tmp/libzip-1.2.0.tar.gz
  cd /tmp
  tar -zxvf libzip-1.2.0.tar.gz && cd libzip-1.2.0
  ./configure
  make && make install
  echo 'export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig/"' >> /etc/profile
  source /etc/profile
}
# 安装 PHP 8.2 及其扩展
install_php() {
  echo "安装 Remi 仓库和 PHP 8.2..."
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
}
# 安装 Composer 并配置阿里云镜像源
install_composer() {
  echo "安装 Composer..."
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
  echo "Composer 安装和配置完成！"

}
# 克隆项目代码库并设置权限
setup_project() {
  echo "克隆项目代码库..."
  mkdir -p /www/yuetougz.com/sucai
  cd /www/yuetougz.com/sucai/
  git clone http://kuangzhuoqi:Kzq010524%40@gitlab.yuetougz.com:5006/sucai/sucai-cms-backend.git
  cd /www/yuetougz.com/sucai/sucai-cms-backend
  setfacl -R -d -m g::rwx storage
  setfacl -R -d -m u::rwx storage
  setfacl -R -d -m o::rwx storage
  chmod -R 777 storage
  composer install
}
# 执行模块
execute_module() {
  case $1 in
    source_setup)
      source_setup
      ;;
    install_dependencies)
      install_dependencies
      ;;
    install_libzip)
      install_libzip
      ;;
    install_php)
      install_php
      ;;
    install_composer)
      install_composer
      ;;
    setup_project)
      setup_project
      ;;
    all)
      source_setup
      install_dependencies
      install_libzip
      install_php
      install_composer
      setup_project
      ;;
    *)
      echo "无效参数：$1"
      echo "用法：$0 {source_setup|install_dependencies|install_libzip|install_php|install_composer|setup_project|all}"
      exit 1
      ;;
  esac
}
# 检查是否传入参数
if [ $# -eq 0 ]; then
  echo "未指定模块，将默认执行所有模块..."
  execute_module all
else
  execute_module "$1"
fi
echo "脚本执行完成！"
