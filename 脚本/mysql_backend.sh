#!/bin/bash

# 设置数据库连接信息
DB_NAME="sucai_cms"
DB_USER="root"
DB_PASS="2P8ZiVb20Yna3DV1@"
DB_HOST="192.168.100.202"

# 设置备份目录和文件名
BACKUP_DIR="/data/mysql-bak"
DATE=$(date +'%Y%m%d%H%M%S')
BACKUP_FILE="${BACKUP_DIR}/sucai_cms_backup_${DATE}.sql"

# OSS 配置信息
OSS_BUCKET="jln-yuetougz"  # 你的 OSS 桶名
OSS_PATH="mysql-backend/sucai_cms"  # 上传的 OSS 路径

# 创建备份目录（如果不存在）
mkdir -p $BACKUP_DIR

# 执行数据库备份
echo "正在备份数据库: $DB_NAME ..."
mysqldump -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME > $BACKUP_FILE

# 检查备份是否成功
if [ $? -eq 0 ]; then
  echo "备份成功: $BACKUP_FILE"
else
  echo "备份失败!"
  exit 1
fi

# 上传备份文件到 OSS
echo "正在上传备份文件到 OSS: $OSS_BUCKET/$OSS_PATH/"
ossutil cp $BACKUP_FILE oss://$OSS_BUCKET/$OSS_PATH/

# 检查上传是否成功
if [ $? -eq 0 ]; then
  echo "上传成功: oss://$OSS_BUCKET/$OSS_PATH/$(basename $BACKUP_FILE)"
else
  echo "上传失败!"
  exit 1
fi

#rm -f $BACKUP_FILE


