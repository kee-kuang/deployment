#!/bin/bash

# 获取传入的变量值
old_num=$1
new_num=$2

cd /etc/supervisord.d/

# 下载文件
echo "正在下载文件..."
wget https://jln-yuetougz.oss-cn-guangzhou.aliyuncs.com/bak.zip 

# 解压文件
echo "正在解压文件..."
unzip bak.zip
mv bak/* ./

# 删除压缩文件
echo "正在删除压缩文件..."
rm -rf bak.zip bak

# 重命名文件
echo "正在重命名文件..."
rename 2 $new_num *

# 替换文件中的字符串
echo "正在替换文件中的字符串..."
for file in *.ini; do
    # 只替换 command 和 stdout_logfile 行的第一个数字
    if [[ $file == "sucai-cms-video-fission-result-upload-tos-${new_num}-2.ini" ]]; then
        # 只替换 command 中的第一个数字 2
        sed -i "0,/command=php \/www\/yuetougz\.com\/sucai\/sucai-cms-backend\/artisan queue:listen rabbitmq --queue=video_fission_result_upload_tos_${old_num}_2/ {s/_${old_num}_2/_${new_num}_2/}" "$file"
        # 只替换 stdout_logfile 中的第一个数字 2
        sed -i "0,/stdout_logfile=\/var\/log\/sucai-cms-video-fission-result-upload-tos_test_${old_num}_2\.log/ {s/_${old_num}_2/_${new_num}_2/}" "$file"
    else
        # 对其他文件进行全局替换
        sed -i "s/_${old_num}/_${new_num}/g" "$file"
    fi
done

echo "所有操作已完成。"
