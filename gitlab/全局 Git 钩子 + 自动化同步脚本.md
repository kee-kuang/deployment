### **全局 Git 钩子 + 自动化同步脚本**

**原理**：在 GitLab 服务器上为所有仓库配置全局 `post-receive` 钩子，当任何仓库收到代码推送时，自动触发镜像同步到阿里云对应仓库。

------

#### **步骤 1：配置 GitLab 服务器到阿里云的 SSH 认证**

1. **生成全局 SSH 密钥对**（GitLab 服务器执行）：

   ```
   sudo -u git ssh-keygen -t ed25519 -C "2272765894@qq.com" -f /var/opt/gitlab/.ssh/aliyun_mirror
   ```

2. **将公钥添加到阿里云 GitLab**：

   - 将 `/var/opt/gitlab/.ssh/aliyun_mirror.pub` 内容添加到阿里云 GitLab 的：
     - **个人账户 SSH Keys**（推荐）：若使用一个专用账号同步。
     - **项目 Deploy Keys**：若需按仓库授权（需为每个仓库单独添加，不推荐批量）。

------

#### **步骤 2：编写全局同步钩子脚本**

1. **创建钩子脚本** `/var/opt/gitlab/mirror-sync.sh`：

   ```
   #!/bin/bash
   # 自动将本地仓库同步到阿里云 GitLab
   REPO_PATH="$1"
   ALIYUN_GITLAB="git@aliyun.example.com"  # 替换为阿里云 GitLab 地址
   
   # 提取仓库路径（适配 GitLab 的存储结构 /var/opt/gitlab/git-data/repositories/@hashed/...）
   repo_fullname=$(echo "$REPO_PATH" | sed -n 's#.*/repositories/\(.*\)\.git#\1#p' | tr '/' ':')
   
   # 若阿里云仓库路径与本地一致，直接同步
   git push --mirror "$ALIYUN_GITLAB:$repo_fullname.git"
   ```

   - **赋予执行权限**：

     ```
     chmod +x /var/opt/gitlab/mirror-sync.sh
     ```

2. **配置全局 `post-receive` 钩子模板**（GitLab 服务器执行）：

   ```
   # 创建全局钩子模板目录
   mkdir -p /opt/gitlab/embedded/service/gitlab-shell/hooks/post-receive.d
   
   # 创建全局钩子脚本
   cat <<EOF > /opt/gitlab/embedded/service/gitlab-shell/hooks/post-receive.d/mirror-sync
   #!/bin/bash
   /var/opt/gitlab/mirror-sync.sh "$GL_REPOSITORY" >> /var/log/gitlab/mirror-sync.log 2>&1
   EOF
   
   # 赋予执行权限
   chmod +x /opt/gitlab/embedded/service/gitlab-shell/hooks/post-receive.d/mirror-sync
   ```

3. **为所有现有仓库应用钩子**：

   ```
   # 遍历所有仓库目录，强制更新钩子
   find /var/opt/gitlab/git-data/repositories -name "*.git" -type d | while read repo; do
     ln -sf /opt/gitlab/embedded/service/gitlab-shell/hooks/post-receive.d/mirror-sync "$repo/hooks/post-receive"
   done
   ```

------

#### **步骤 3：自动创建阿里云仓库（可选）**

若阿里云 GitLab 中尚未创建对应仓库，可在同步前自动创建：

1. **在阿里云 GitLab 创建 Access Token**：

   - 生成一个有 `api` 权限的 Token，保存为 `ALIYUN_TOKEN`。

2. **修改 `mirror-sync.sh` 脚本**，添加仓库创建逻辑：

   ```
   #!/bin/bash
   REPO_PATH="$1"
   ALIYUN_GITLAB="git@aliyun.example.com"
   ALIYUN_API="https://aliyun.example.com/api/v4"
   ALIYUN_TOKEN="your-access-token"
   
   # 提取仓库路径（如 group/subgroup/project）
   repo_fullname=$(echo "$REPO_PATH" | sed -n 's#.*/repositories/\(.*\)\.git#\1#p' | tr '/' ':')
   
   # 检查阿里云仓库是否存在，不存在则创建
   response=$(curl -s -o /dev/null -w "%{http_code}" -H "PRIVATE-TOKEN: $ALIYUN_TOKEN" "$ALIYUN_API/projects/$repo_fullname")
   if [ "$response" = "404" ]; then
     # 创建项目（注意路径编码）
     group_name=$(dirname "$repo_fullname" | tr ':' '/')
     project_name=$(basename "$repo_fullname")
     curl -s -X POST -H "PRIVATE-TOKEN: $ALIYUN_TOKEN" \
       -d "name=$project_name" \
       -d "path=$project_name" \
       -d "namespace_id=$(curl -s -H "PRIVATE-TOKEN: $ALIYUN_TOKEN" "$ALIYUN_API/namespaces?search=$group_name" | jq -r '.[0].id')" \
       "$ALIYUN_API/projects"
   fi
   
   # 同步代码
   git push --mirror "$ALIYUN_GITLAB:$repo_fullname.git"
   ```

------

### **步骤 4：验证与监控**

1. **触发测试推送**：

   ```
   # 在任意本地仓库执行
   git commit --allow-empty -m "Trigger sync test"
   git push
   ```

2. **检查同步结果**：

   - 查看阿里云 GitLab 对应仓库是否更新。
   - 检查日志 `/var/log/gitlab/mirror-sync.log`。

------

### **关键优化与注意事项**

1. **性能优化**：

   - **异步推送**：若仓库量大，可在脚本中使用 `nohup` 或任务队列异步执行，避免阻塞 Git 推送：

     ```
     nohup git push --mirror "$ALIYUN_GITLAB:$repo_fullname.git" >/dev/null 2>&1 &
     ```

   - **限速同步**：添加 `git push --mirror --porcelain` 控制速率。

2. **错误处理**：

   - 脚本中增加重试逻辑和邮件告警：

     ```
     max_retries=3
     retry_count=0
     until git push --mirror "$ALIYUN_GITLAB:$repo_fullname.git"; do
       retry_count=$((retry_count+1))
       if [ $retry_count -ge $max_retries ]; then
         echo "Sync failed after $max_retries attempts" | mail -s "Sync Error" admin@example.com
         exit 1
       fi
       sleep 60
     done
     ```

3. **权限与安全**：

   - 限制 `git` 用户对脚本和日志文件的访问权限：

     ```
     chown -R git:git /var/opt/gitlab/mirror-sync.*
     chmod 600 /var/opt/gitlab/.ssh/aliyun_mirror
     ```

------

### **方案优势**

- **全自动化**：无需开发人员参与，无需逐个仓库配置。
- **实时同步**：代码推送后秒级触发同步。
- **弹性扩展**：支持数千仓库的批量同步。
- **低维护成本**：一次部署，长期生效。

通过此方案，您只需在 GitLab 服务器端完成一次配置，即可实现所有仓库和分支的实时单向同步，完美适配多仓库管理的运维场景。