#!/bin/bash
set -e

APP_ROOT="/www/yuetougz.com/cid-front-prod"
RELEASE_DIR="$APP_ROOT/releases"
CURRENT_LINK="$APP_ROOT/current"
ROLLBACK_LINK="$APP_ROOT/rollback"

TAR="/tmp/cid-front.tar.gz"
VERSION=$(date +%Y%m%d_%H%M%S)
TARGET="$RELEASE_DIR/$VERSION"

echo "==> 发布版本: $VERSION"

# 1. 创建新版本目录
mkdir -p "$TARGET"

# 2. 解压
tar -xzf "$TAR" -C "$TARGET"

# 3. 校验
if [ ! -f "$TARGET/index.html" ]; then
    echo "❌ index.html 不存在，终止发布"
    exit 1
fi

# 4. 记录回滚点
if [ -L "$CURRENT_LINK" ]; then
    PREV=$(readlink "$CURRENT_LINK")
    ln -sfn "$PREV" "$ROLLBACK_LINK"
fi
#设置软链接
ln -sfn "$TARGET" "$CURRENT_LINK"

# 7. 清理旧版本（保留 5 个）
cd "$RELEASE_DIR"
ls -1dt */ | tail -n +6 | xargs rm -rf

echo "✅ 发布成功: $VERSION"