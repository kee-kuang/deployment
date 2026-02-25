#!/bin/bash

LOG_DIR="/usr/local/webserver/nginx/logs"

# 获取当前日期和昨天的日期
now_date=$(date +'%Y%m%d')
yesterday_date=$(date -d "$now_date -1 day" +'%Y%m%d')

# 进入日志目录
cd "$LOG_DIR"

# 创建昨天的目录
mkdir -p "$yesterday_date"
mv *-"$yesterday_date"* "$yesterday_date"

# 初始化变量
declare -a dirs
start_date=""
end_date=""

# 查找最近的7个目录
find . -maxdepth 1 -type d -name "*[0-9]*" | while read -r dir; do
    dir_date=$(basename "$dir")
    if [[ -z "$start_date" ]]; then
        start_date=$dir_date
    fi
    end_date=$dir_date
    dirs+=("$dir")
    if [[ "${#dirs[@]}" -eq 7 ]]; then
        break
    fi
done

# 检查是否满足7天周期
if [[ "${#dirs[@]}" -eq 7 ]]; then
    tar_name="${start_date}-${end_date}"
    # 打包文件夹
    tar -czf "${tar_name}.tar.gz" "${dirs[@]}"
    
    # 删除打包的文件夹
    for dir in "${dirs[@]}"; do
        rm -rf "$dir"
    done
    
    echo "Packed and removed ${tar_name}.tar.gz"
else
    echo "Not enough directories to pack."
fi

# 删除一个月前的tar包
find . -type f -name "*.tar.gz" -mtime +30 | xargs rm -f
echo "Deleted .tar.gz files older than one month"