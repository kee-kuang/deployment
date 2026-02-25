#!/bin/bash

remote_dir="/www-ssd/sucai/prod/sucai-cms-front"
update_dir="/www-ssd/sucai/prod/sucai-cms-front-upstream"
tarball="/sucai-front.tar.gz"
nginx_conf="/etc/nginx/conf.d/sucai/sucai-front.conf"

# 解压并设置权限
extract_and_set_permissions() {
  local dir=$1
  echo "清理目录: $dir"
  rm -rf "${dir:?}/"*  # 安全删除目录内容，保留目录本身
  if [ $? -ne 0 ]; then
    echo "错误：清理目录失败，请检查权限或路径"
    exit 1
  fi

  echo "解压文件到: $dir"
  tar -xf "$tarball" -C "$dir"
  if [ $? -ne 0 ]; then
    echo "错误：解压失败，请检查压缩包是否存在或权限"
    exit 1
  fi
}

# 修改Nginx配置（精确匹配目标root行）
modify_nginx_config() {
  local target_dir=$1
  local conf_file=$2

  # 备份原配置
  cp "$conf_file" "$conf_file.bak"
  echo "配置文件已备份至: $conf_file.bak"

  # 使用正则表达式精确匹配目标root行（避免影响其他root指令）
  sed -i "s|root\s\+/www-ssd/sucai/prod/sucai-cms-front[^;]*;|root $target_dir/dist-prod;|g" "$conf_file"

  # 验证替换结果
  if grep -q "root $target_dir/dist-prod;" "$conf_file"; then
    echo "Nginx路径已更新为: $target_dir/dist-prod"
  else
    echo "错误：Nginx路径更新失败，请检查配置语法"
    exit 1
  fi
}

# 选择较新的目录作为部署目标
if [ -d "$remote_dir" ] && [ -d "$update_dir" ]; then
  if [ $(stat -c %Y "$remote_dir") -lt $(stat -c %Y "$update_dir") ]; then
    echo "检测到 $update_dir 更新，使用此目录部署"
    target_dir=$update_dir
  else
    echo "检测到 $remote_dir 更新，使用此目录部署"
    target_dir=$remote_dir
  fi
else
  echo "错误：目录 $remote_dir 或 $update_dir 不存在"
  exit 1
fi

# 执行解压和权限设置
extract_and_set_permissions "$target_dir"

# 修改Nginx配置
modify_nginx_config "$target_dir" "$nginx_conf"

# 测试并重载Nginx
echo "测试Nginx配置..."
/usr/sbin/nginx -t
if [ $? -eq 0 ]; then
  echo "重载Nginx服务..."
  /usr/sbin/nginx -s reload
  echo "部署成功！Nginx已使用新配置运行"
else
  echo "错误：Nginx配置测试失败，请检查日志"
  exit 1
fi