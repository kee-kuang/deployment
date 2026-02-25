

# 腾讯云 GooseFS-Lite 工具使用文档(cos挂载到本地)

## 1. 功能说明
GooseFS-Lite 工具支持将对象存储（Cloud Object Storage，COS）存储桶挂载到本地，像使用本地文件系统一样直接操作腾讯云对象存储中的对象。
- **高性能**：相比于 COSFS 工具，GooseFS-Lite 可提供更高的大文件读写速度，不受本地磁盘的性能限制。
- **功能支持**：支持 POSIX 文件系统的主要功能，例如文件顺序/随机读、顺序写、目录操作等。

## 2. 使用限制
GooseFS-Lite 仅适合挂载后对文件进行简单的管理，不支持本地文件系统的一些高级功能。
- **写操作**：不支持对文件进行随机写和 `truncate` 操作；不支持读取和 `rename` 当前挂载点正在写入的文件。
- **并发**：多个客户端挂载同一个 COS 存储桶时，需用户自行协调行为（如避免同时写同一个文件）。
- **原子性**：文件/文件夹的 `rename` 操作非原子操作。
- **元数据**：元数据操作（如 `list directory`）性能较差，因需要远程访问 COS 服务器。
- **文件系统特性**：不支持 soft/hard link。
- **追加写**：性能较差，涉及服务端数据拷贝和下载被追加文件。
- **环境要求**：不建议在小内存场景（如内存 < 2G）使用；容器环境目前仅支持腾讯云 TKE。
- **费用提示**：外网挂载和非低频存储的追加写操作会产生下载流量费用。

## 3. 使用环境
- **JDK**：KonaJDK 11
- **操作系统**：Linux X86_64

---

## 4. 安装与配置流程

### 步骤1：安装依赖

**CentOS/TencentOS Server:**
```bash
yum install -y fuse-devel
```

**Ubuntu:**

Bash

```
apt install -y libfuse-dev
```

**其他 Linux 发行版（编译安装 libfuse）:**

Bash

```
wget "[https://github.com/libfuse/libfuse/releases/download/fuse-2.9.7/fuse-2.9.7.tar.gz](https://github.com/libfuse/libfuse/releases/download/fuse-2.9.7/fuse-2.9.7.tar.gz)"
tar xvf fuse-2.9.7.tar.gz
cd fuse-2.9.7
./configure
make -j8
make install
```

### 步骤2：安装 GooseFS-Lite

将 GooseFS-Lite 安装到当前目录，并建立软链接：

Bash

```
curl -fssL [https://downloads.tencentgoosefs.cn/goosefs-lite/install.sh](https://downloads.tencentgoosefs.cn/goosefs-lite/install.sh) | sh -x
cd goosefs-lite-*
sudo bash bin/install.sh
```

### 步骤3：安装 KonaJDK11

在 `goosefs-lite-<版本号>` 目录下执行（以 1.0.6 为例）：

Bash

```
sudo bash bin/install-jdk.sh [https://github.com/Tencent/TencentKona-11/releases/download/kona11.0.22/TencentKona-11.0.22.b1-jdk_linux-x86_64.tar.gz](https://github.com/Tencent/TencentKona-11/releases/download/kona11.0.22/TencentKona-11.0.22.b1-jdk_linux-x86_64.tar.gz)
```

### 步骤4：修改配置文件

进入 `conf/` 目录修改 `core-site.xml`。

您可以使用 sed 命令快速替换（请将 `$SECRET_ID`, `$SECRET_KEY`, `$REGION` 替换为实际值）：

Bash

```
sed -i '/<name>fs.cosn.userinfo.secretId<\/name>/{N;s/<value>[^<]*<\/value>/<value>$SECRET_ID<\/value>/}' conf/core-site.xml
sed -i '/<name>fs.cosn.userinfo.secretKey<\/name>/{N;s/<value>[^<]*<\/value>/<value>$SECRET_KEY<\/value>/}' conf/core-site.xml
sed -i '/<name>fs.cosn.bucket.region<\/name>/{N;s/<value>[^<]*<\/value>/<value>$REGION<\/value>/}' conf/core-site.xml
```

或者手动编辑 `conf/core-site.xml`：

- `fs.cosn.userinfo.secretId`: 腾讯云密钥 ID
- `fs.cosn.userinfo.secretKey`: 腾讯云密钥 Key
- `fs.cosn.bucket.region`: 存储桶地域

------

## 5. 挂载与卸载

### 挂载存储桶

Bash

```
# 1. 创建挂载点（必须为空目录）
mkdir -p /mnt/goosefs-lite-mnt

# 2. 执行挂载
# 格式: ./bin/goosefs-lite mount <本地目录> cosn://<存储桶名称>/
./bin/goosefs-lite mount /mnt/goosefs-lite-mnt/ cosn://examplebucket-1250000000/

# 3. 查看挂载状态
./bin/goosefs-lite stat
```

> **提示**：如需允许其他用户访问或只读挂载，可增加 `-o` 参数，例如：
>
> ```
> ./bin/goosefs-lite mount -o "ro,allow_other" ...
> ```

### 卸载挂载点

Bash

```
./bin/goosefs-lite umount /mnt/goosefs-lite-mnt

# 如果卸载异常（如提示 device busy），可尝试强制卸载
sudo umount -l /mnt/goosefs-lite-mnt
```

------

## 6. 配置开机自启动 (Systemd)

通过配置 Systemd 服务实现开机自动挂载。

1. **编辑服务文件**

   创建并编辑 `/usr/lib/systemd/system/goosefs-lite.service`，写入以下内容：

   Ini, TOML

   ```
   [Unit]
   Description=The Tencent Cloud GooseFS Lite for COS
   Requires=network-online.target
   After=network-online.target
   
   [Service]
   Type=forking
   User=root
   # 内存配置重要提示：
   # -Xms 和 -Xmx 总和建议不超过节点物理内存的 50%。
   # 下例假设机器内存充足，配置了 2G-4G 堆内存，请根据实际情况修改。
   Environment="JAVA_OPTS=-Xms2G -Xmx4G -XX:MaxDirectMemorySize=1G -XX:+UseG1GC -XX:G1HeapRegionSize=32m"
   
   # ！！！请修改为您的实际安装路径、挂载点和存储桶地址！！！
   ExecStart=/usr/local/goosefs-lite-1.0.6/bin/goosefs-lite mount /mnt/goosefs-mnt cosn://examplebucket-1250000000/
   ExecStop=/usr/local/goosefs-lite-1.0.6/bin/goosefs-lite umount /mnt/goosefs-mnt
   
   Restart=always
   RestartSec=5
   
   [Install]
   WantedBy=multi-user.target
   ```

2. **启用并启动服务**

   Bash

   ```
   # 重载 systemd 配置
   systemctl daemon-reload
   
   # 启动服务
   systemctl start goosefs-lite
   
   # 设置开机自启
   systemctl enable goosefs-lite
   
   # 查看运行状态
   systemctl status goosefs-lite
   ```

------

## 7. 参数调优

### core-site.xml 常用参数 (conf/core-site.xml)

| **属性键**                      | **说明**                                          | **默认值**    |
| ------------------------------- | ------------------------------------------------- | ------------- |
| `fs.cosn.useHttps`              | 是否使用 HTTPS 传输                               | true          |
| `fs.cosn.upload.part.size`      | 分块上传大小 (最大支持 10000 块，单文件最大 19TB) | 8388608 (8MB) |
| `fs.cosn.upload_thread_pool`    | 并发上传线程数                                    | 32            |
| `fs.cosn.read.ahead.block.size` | 预读块大小                                        | 1048576 (1MB) |

### goosefs-lite.properties 常用参数 (conf/goosefs-lite.properties)

| **属性**                                              | **说明**                   | **默认值** |
| ----------------------------------------------------- | -------------------------- | ---------- |
| `goosefs.fuse.list.entries.cache.enabled`             | 是否开启客户端 List 缓存   | true       |
| `goosefs.fuse.list.entries.cache.max.size`            | 客户端 List 最大缓存条目数 | 100000     |
| `goosefs.fuse.list.entries.cache.max.expiration.time` | 缓存有效时间 (ms)          | 15000      |
| `goosefs.fuse.async.release.max.wait.time`            | 写操作时等待完成时间 (ms)  | 5000       |
| `goosefs.fuse.umount.timeout`                         | 卸载等待超时时间 (ms)      | 120000     |