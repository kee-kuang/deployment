#!/bin/bash

remote_dir="/www/yuetougz.com/backend"
update_dir="/www/yuetougz.com/backend-upstream"
tarball="/cid.tar.gz"
env_file="/root/.env"
nginx_conf="/etc/nginx/conf.d/backend-yuetougz.com.conf"

extract_and_set_permissions() {
  local dir=$1
  rm -rf "${dir:?}/"*
  tar -xzf "$tarball" -C "$dir"
  chmod -R 777 "$dir/storage"
  cp -r "$env_file" "$dir"
  composer update --working-dir="$dir"
}

modify_nginx_config() {
  local target_dir=$1
  local conf_file=$2

  cp "$conf_file" "$conf_file.bak"

  sed -i "s|root .*;|root $target_dir/public;|g" "$conf_file"

  if grep -q "root $target_dir/public;" "$conf_file"; then
    echo "Nginx 路径已更新"
  else
    echo "Nginx 路径更新失败."
    exit 1
  fi
}

if [ $(stat -c %Y "$remote_dir") -lt $(stat -c %Y "$update_dir") ]; then
  echo "Using $remote_dir as it is more recent."
  target_dir=$remote_dir
else
  echo "Using $update_dir as it is more recent."
  target_dir=$update_dir
fi

exit 1

extract_and_set_permissions "$target_dir"

sleep 3

modify_nginx_config "$target_dir" "$nginx_conf"


systemctl reload nginx

if [ $? -eq 0 ]; then
  echo "successfully."
else
  echo "Failed"
  exit 1
fi
