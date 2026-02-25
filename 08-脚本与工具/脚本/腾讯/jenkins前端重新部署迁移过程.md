# jenkins前端重新部署迁移过程

# 一、修改Nginx（非常重要）

## 1️⃣ Nginx 只改一次 root（之后永远不动）

```
root /www/yuetougz.com/front/current;
```

确认：

```
nginx -t && nginx -s reload
```

> 到此为止，**nginx 配置生命周期结束**

------

## 2️⃣ 在所有前端机器上准备目录

```
mkdir -p /www/yuetougz.com/big-admin-front/{releases,shared}
chown -R ubuntu:www-data /www/yuetougz.com/front
```

------

# 二、最终 Jenkinsfile

> 新建 **Pipeline Job**
>  SCM：和现在一样
>  Script from SCM：`Jenkinsfile`

```
pipeline {
    agent any

    tools {
        nodejs 'NodeJs-16.20.2'
    }

    options {
        disableConcurrentBuilds()
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }

    environment {
        TAR_NAME = 'cid-front.tar.gz'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: 'master']],
                    userRemoteConfigs: [[
                        url: 'http://gitlab.yuetougz.com:5006/zhou/ytcid.git',
                        credentialsId: '93efbd9e-c5b8-4294-bec3-72225fbcacea'
                    ]]
                ])
            }
        }

        stage('Build') {
            steps {
                sh '''
                    node -v
                    npm install --registry=https://registry.npmmirror.com/
                    npm run build:prod
                '''
            }
        }

        stage('Package') {
            steps {
                sh '''
                    rm -f ${TAR_NAME}
                    tar -czf ${TAR_NAME} dist-prod
                    ls -lh ${TAR_NAME}
                '''
            }
        }

        stage('Deploy') {
            steps {
                script {
                    def servers = [
                        [name: 'tx-master'],
                        [name: 'tx-slave']
                    ]

                    for (s in servers) {
                        sshPublisher(
                            publishers: [
                                sshPublisherDesc(
                                    configName: s.name,
                                    transfers: [
                                        sshTransfer(
                                            sourceFiles: TAR_NAME,
                                            remoteDirectory: '/tmp',
                                            execCommand: 'bash /www/script/cid-front-prod-release.sh',
                                            execTimeout: 120000
                                        )
                                    ],
                                    verbose: false
                                )
                            ]
                        )
                    }
                }
            }
        }
    }

    post {
        success {
            echo '✅ 前端零中断发布完成'
        }
        failure {
            echo '❌ 前端发布失败'
        }
        always {
            cleanWs()
        }
    }
}
```

> 注意：
>
> - **不再区分 prod / http / https 脚本**
> - 所有机器统一执行一个脚本
> - Jenkins 只负责：**传包 + 执行**

------

# 三、最终远端发布脚本（核心）

路径（所有机器一致）：

```
/www/script/front-release.sh
```

内容如下（可直接复制）：

```
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

# 5. 原子切换（零中断关键）
ln -sfn "$TARGET" "$CURRENT_LINK"

# 6. 权限修复
#chown -R www:www "$TARGET"

# 7. 清理旧版本（保留 5 个）
cd "$RELEASE_DIR"
ls -1dt */ | tail -n +6 | xargs rm -rf

echo "✅ 发布成功: $VERSION"
```

赋权：

```
chmod +x /www/script/front-release.sh
```

## 服务器准备工作



------

## 1️⃣ 进入 root（一次性操作）

```
sudo -i
```

------

## 2️⃣ 创建目录结构

```
mkdir -p /www/yuetougz.com/cid-front/{releases,shared}
```

## 3️⃣ 设置目录权限（标准生产环境）

```
chown -R ubuntu:www-data /www/yuetougz.com/cid-front
chown -h ubuntu:www-data /www/yuetougz.com/cid-front/current
chmod -R 755 /www/yuetougz.com/cid-front
sudo chown -R ubuntu:www-data /www
sudo chmod -R 755 /www
```

> ubuntu：部署操作
>  www-data：nginx worker 读取

------

## 5️⃣ 切回 ubuntu 用户（用于 Jenkins 发布）

```
su - ubuntu
```

测试 ubuntu 能操作：

```
mkdir -p /www/yuetougz.com/cid-front/releases/test2
ln -sfn /www/yuetougz.com/cid-front/releases/test2 /www/yuetougz.com/cid-front/current
ls -ld /www/yuetougz.com/cid-front/current
```

> 输出应显示 `lrwxrwxrwx 1 ubuntu www-data ... current -> .../test2`

------

## 6️⃣ 确认 nginx 配置指向 current

```
# nginx 配置示例：
root /www/yuetougz.com/cid-front/current;
```

测试配置并 reload nginx：

```
sudo nginx -t
sudo systemctl reload nginx
```

> reload，不会断开现有连接

------

## 7️⃣ Jenkins 发布时操作示例（ubuntu 用户执行）

假设你已经在 Jenkins 中打包生成 `cid-front.tar.gz`：

```
# 切换到发布目录
cd /www/yuetougz.com/cid-front/releases

# 创建新版本目录
mkdir 20251227_1200
tar -xzf /tmp/cid-front.tar.gz -C 20251227_1200

# 切换 current 软链接
ln -sfn /www/yuetougz.com/cid-front/releases/20251227_1200 /www/yuetougz.com/cid-front/current

# reload nginx
sudo systemctl reload nginx
```

------

## 8️⃣ 回滚示例（秒级回滚）

```
ln -sfn /www/yuetougz.com/cid-front/releases/上一个版本 /www/yuetougz.com/cid-front/current
sudo systemctl reload nginx
```