## 在 CentOS 上安装 FFmpeg

### 方法一：在线安装
```
一、添加 EPEL 和 RPM Fusion 源：

sudo yum install epel-release -y 
sudo yum install https://download1.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm -y 

二、安装 FFmpeg
yum install ffmpeg ffmpeg-devel -y 
```

### 方法二：手动下载并安装预编译版本
```
一、下载 FFmpeg 的预编译二进制文件：

sudo curl -O https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz

https://jln-yuetougz.oss-cn-guangzhou.aliyuncs.com/package/ffmpeg-release-amd64-static.tar.xz
解压并安装：
tar -xvf ffmpeg-release-amd64-static.tar.xz
sudo mv ffmpeg-*-static/ffmpeg /usr/local/bin/
sudo mv ffmpeg-*-static/ffprobe /usr/local/bin/
ffmpeg -version
```

