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
  wget https://jln-yuetougz.oss-cn-guangzhou.aliyuncs.com/ffmpeg-7.1.tar.gz
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
