# jenkins-标准发布

针对我们jenkins 的更新版本的需求,做以下更新

###    一、整体目标（发布设计原则）

**目标只有 5 个：**

1. **前端发布不改 Nginx 配置**

2. **发布过程不 reload / restart Nginx**

3. **发布过程用户无感知**

4. **秒级回滚**

5. **Jenkins 全自动**

   ### 二、标准目录结构（固定）

   > **所有前端项目统一用这一套结构**

```bash
/www/
└── yuetougz.com/
    └── front/
        ├── releases/          # 每次发布一个完整版本
        │   ├── 20250108_101530/
        │   ├── 20250109_153012/
        │   └── 20250110_204422/
        ├── current -> releases/20250110_204422   # 当前线上版本（软链）
        ├── rollback -> releases/20250109_153012  # 上一个稳定版本
        └── shared/            # 可选（如 favicon、robots.txt）

```

   ### 三、Nginx 配置（一次性完成）

> **以后 100% 不再改* (固定每个项目更新)

```bash
server {
    listen 1020 ssl;
    server_name cid.yuetougz.com;

    ssl_certificate      cert/yuetougz/cid.yuetougz.com.pem;
    ssl_certificate_key  cert/yuetougz/cid.yuetougz.com.key;

    root /www/yuetougz.com/front/current; #固定使用current 作为当前版本使用
    index index.html;

    access_log /www/logs/cid.yuetougz.com_access.log;
    error_log  /www/logs/cid.yuetougz.com_error.log;

    location / {
        add_header Cache-Control "no-cache, no-store, must-revalidate";
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(js|css|png|jpg|svg|woff2)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    location /api/ {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass https://api.yuetougz.com;
    }
}

```

# 四、Jenkins 标准发布流程（核心）

## 1️⃣ Jenkins Job 类型

- **Freestyle** 或 **Pipeline** 均可
- 以下以 **Shell 脚本** 为准（你直接复制就能用）

------

## 2️⃣ Jenkins 构建产物规范

前端构建完成后，生成：

```
dist.tar.gz
```

**tar 包内结构必须是：**

```
index.html
assets/
js/
css/
```

------

## 3️⃣ 标准发布脚本

```bash
#!/bin/bash
set -e

APP_ROOT="/www/yuetougz.com/front" #确认发布路径
RELEASE_DIR="$APP_ROOT/releases"
CURRENT_LINK="$APP_ROOT/current"
ROLLBACK_LINK="$APP_ROOT/rollback"

VERSION=$(date +%Y%m%d_%H%M%S)
TARGET="$RELEASE_DIR/$VERSION"

echo "==> 发布版本: $VERSION"

# 1. 创建新版本目录
mkdir -p "$TARGET"

# 2. 解压新版本
tar -xzf dist.tar.gz -C "$TARGET"

# 3. 基本校验
if [ ! -f "$TARGET/index.html" ]; then
    echo "❌ index.html 不存在，发布中断"
    exit 1
fi

# 4. 记录当前版本用于回滚
if [ -L "$CURRENT_LINK" ]; then
    PREV=$(readlink "$CURRENT_LINK")
    ln -sfn "$PREV" "$ROLLBACK_LINK"
fi

# 5. 原子切换版本
ln -sfn "$TARGET" "$CURRENT_LINK"

echo "✅ 发布完成，当前版本: $VERSION"

# 6. 清理旧版本（保留最近 5 个）
cd "$RELEASE_DIR"
ls -1dt */ | tail -n +6 | xargs rm -rf
```

# 五、回滚流程

```
ln -sfn /www/yuetougz.com/front/rollback /www/yuetougz.com/front/current
```

# 六、“改配置发布” → “标准发布”的迁移步骤

1. 创建目录结构
2. 修改 nginx root 为 `current`
3. **只 reload 一次**
4. 之后永久不用动 nginx