#!/bin/bash

# 设置文件路径和下载目录
file_path=""
output_dir=""

# 创建下载目录
mkdir -p "$output_dir"

# 使用正则表达式匹配链接并下载
grep -Eo 'https?://\S+' "$file_path" | while read -r url; do
    # 获取文件名部分
    file_name=$(basename "$url")
    # 下载链接到指定目录
    wget "$url" -P "$output_dir"
done

echo "下载完成!"

