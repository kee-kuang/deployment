# php 插件 swoole 部署

### 下载

```
官网github地址：https://github.com/swoole/swoole-src/releases
官网地址：https://wiki.swoole.com/zh-cn/#/environment
https://www.swoole.com/
极乐鸟公司oss下载地址：
wget https://jln-yuetougz.oss-cn-guangzhou.aliyuncs.com/package/swoole-src-5.1.7.zip
wget https://jln-yuetougz.oss-cn-guangzhou.aliyuncs.com/package/swoole-src-6.0.1.zip
```

### 编译安装

```
cd swoole-src && \
phpize && \
./configure --with-php-config=/opt/remi/php82/root/usr/bin/php-config --enable-openssl&& \
 yum install brotli-devel && \
sudo make && sudo make install
```

### 启动扩展

```
vim php.ini
extension=swoole.so
```

