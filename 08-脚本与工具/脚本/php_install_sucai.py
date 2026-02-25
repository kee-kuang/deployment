import subprocess
import sys
import os

# 执行系统命令的辅助函数
def run_command(command, shell=False):
    print(f"执行命令: {command}")
    result = subprocess.run(command, shell=shell, text=True, capture_output=True)
    if result.returncode != 0:
        print(f"命令失败: {result.stderr}")
        sys.exit(result.returncode)
    else:
        print(result.stdout)

# 配置阿里云源
def source_setup():
    print("配置阿里云 CentOS 和 EPEL 源...")
    run_command(["curl", "-o", "/etc/yum.repos.d/CentOS-Base.repo", "https://mirrors.aliyun.com/repo/Centos-7.repo"])
    run_command(["curl", "-o", "/etc/yum.repos.d/epel.repo", "http://mirrors.aliyun.com/repo/epel-7.repo"])
    run_command(["yum", "makecache", "-y"], shell=True)
    run_command(["yum", "repolist"], shell=True)

# 安装基础依赖包
def install_dependencies():
    print("安装系统依赖...")
    run_command(["yum", "-y", "install", "epel-release"], shell=True)
    run_command([
        "yum", "install", "-y", "libxml2-devel", "sqlite-devel", "oniguruma", "oniguruma-devel", 
        "libxml2", "libxml2-devel", "bzip2", "bzip2-devel", "libcurl", "libjpeg", "libjpeg-devel",
        "zstd", "libzstd-devel", "curl", "libcurl-devel", "libpng", "libpng-devel", "libffi-devel",
        "libwebp-devel", "openssl-devel", "gcc", "make", "autoconf", "glibc-devel"
    ], shell=True)

# 安装 libzip 1.2.0
def install_libzip():
    print("安装 libzip 1.2.0...")
    run_command(["yum", "remove", "-y", "libzip-devel", "libzip"], shell=True)
    run_command(["wget", "https://keekuang-pubilc.oss-cn-guangzhou.aliyuncs.com/libzip-1.2.0.tar.gz", "-O", "/tmp/libzip-1.2.0.tar.gz"])
    os.chdir("/tmp")
    run_command(["tar", "-zxvf", "libzip-1.2.0.tar.gz"])
    os.chdir("libzip-1.2.0")
    run_command(["./configure"])
    run_command(["make"])
    run_command(["make", "install"])
    with open("/etc/profile", "a") as profile:
        profile.write('\nexport PKG_CONFIG_PATH="/usr/local/lib/pkgconfig/"\n')
    run_command(["source", "/etc/profile"], shell=True)

# 安装 PHP 8.2 和扩展
def install_php():
    print("安装 PHP 8.2 和扩展...")
    run_command(["yum", "install", "-y", "https://mirrors.aliyun.com/remi/enterprise/remi-release-7.rpm"], shell=True)
    run_command(["yum", "-y", "install", "yum-utils"], shell=True)
    run_command(["yum", "install", "-y", "epel-release"], shell=True)
    run_command([
        "yum", "install", "-y", "php82", "php82-php-devel", "php82-php-fpm", "php82-php-mbstring", 
        "php82-php-memcache", "php82-php-memcached", "php82-php-redis", "php82-php-mysqlnd", "php82-php-pdo",
        "php82-php-bcmath", "php82-php-xml", "php82-php-gd", "php82-php-gmp", "php82-php-igbinary", 
        "php82-php-imagick", "php82-php-mcrypt", "php82-php-pdo_mysql", "php82-php-posix", "php82-php-simplexml", 
        "php82-php-opcache", "php82-php-xsl", "php82-php-xmlwriter", "php82-php-xmlreader", "php82-php-swoole", 
        "php82-php-zip", "php82-php-phalcon", "php82-php-yaml", "php82-php-yar", "php82-php-yaf", "php82-php-uuid"
    ], shell=True)
    run_command(["ln", "-sf", "/opt/remi/php82/root/usr/bin/php", "/usr/bin/php"])
    run_command(["systemctl", "enable", "--now", "php82-php-fpm"], shell=True)

# 安装 Composer
def install_composer():
    print("安装 Composer...")
    os.chdir("/opt")
    run_command(["curl", "-sS", "https://getcomposer.org/installer", "-o", "composer-setup.php"])
    expected_checksum = subprocess.run(["curl", "-sS", "https://composer.github.io/installer.sig"], text=True, capture_output=True).stdout.strip()
    actual_checksum = subprocess.run(["php", "-r", "echo hash_file('sha384', 'composer-setup.php');"], text=True, capture_output=True).stdout.strip()
    if expected_checksum != actual_checksum:
        print("安装脚本的哈希校验失败。")
        os.remove("composer-setup.php")
        sys.exit(1)
    run_command(["php", "composer-setup.php", "--install-dir=/usr/local/bin", "--filename=composer"])
    run_command(["ln", "-sf", "/usr/local/bin/composer", "/usr/sbin/composer"])
    run_command(["composer", "config", "-g", "repo.packagist", "composer", "https://mirrors.aliyun.com/composer/"], shell=True)
    print("Composer 安装完成！")

# 克隆项目并设置权限
def setup_project():
    print("克隆项目代码库并设置权限...")
    os.makedirs("/www/yuetougz.com/sucai", exist_ok=True)
    os.chdir("/www/yuetougz.com/sucai")
    run_command(["git", "clone", "http://kuangzhuoqi:Kzq010524%40@gitlab.yuetougz.com:5006/sucai/sucai-cms-backend.git"])
    os.chdir("/www/yuetougz.com/sucai/sucai-cms-backend")
    run_command(["setfacl", "-R", "-d", "-m", "g::rwx", "storage"])
    run_command(["setfacl", "-R", "-d", "-m", "u::rwx", "storage"])
    run_command(["chmod", "-R", "777", "storage"])
    run_command(["composer", "install"], shell=True)

# 模块字典
modules = {
    "source_setup": source_setup,
    "install_dependencies": install_dependencies,
    "install_libzip": install_libzip,
    "install_php": install_php,
    "install_composer": install_composer,
    "setup_project": setup_project
}

# 执行指定模块
def execute_module(module_name):
    if module_name == "all":
        for module in modules.values():
            module()
    elif module_name in modules:
        modules[module_name]()
    else:
        print(f"无效的模块名称: {module_name}")
        print("可用模块: source_setup, install_dependencies, install_libzip, install_php, install_composer, setup_project, all")

# 主函数
if __name__ == "__main__":
    if len(sys.argv) > 1:
        execute_module(sys.argv[1])
    else:
        print("未指定模块，将执行所有模块...")
        execute_module("all")
