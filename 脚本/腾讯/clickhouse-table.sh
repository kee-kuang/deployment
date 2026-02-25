#!/bin/bash
# 批量导出 ClickHouse 表结构，生成可在目标库执行的 SQL
# 处理 COMMENT 和转义字符

SRC_HOST=47.107.173.188
SRC_PORT=9300
SRC_USER=yuetou
SRC_PASS='1qJL8lCl7Gu@C-Y'
DB=cid
OUTPUT_FILE="./cid_create_tables.sql"

# 清空输出文件
> "$OUTPUT_FILE"

# 获取所有表名
TABLES=$(clickhouse-client --host "$SRC_HOST" --port "$SRC_PORT" --user "$SRC_USER" --password "$SRC_PASS" \
         --query="SHOW TABLES FROM \`$DB\`")

for TBL in $TABLES; do
    echo "生成建表语句: $DB.$TBL"

    # 获取建表语句
    CREATE_SQL=$(clickhouse-client --host "$SRC_HOST" --port "$SRC_PORT" --user "$SRC_USER" --password "$SRC_PASS" \
                 --query="SHOW CREATE TABLE \`$DB\`.\`$TBL\`")

    # 处理：
    # 1. 替换 CREATE TABLE 为 CREATE TABLE IF NOT EXISTS
    # 2. 将 \n 替换为换行
    # 3. 将 \' 替换为 '
    CLEAN_SQL=$(echo "$CREATE_SQL" \
                | sed 's/^CREATE TABLE/CREATE TABLE IF NOT EXISTS/' \
                | sed -E 's/\\n/\n/g' \
                | sed -E "s/\\\\'/'/g")

    # 添加分号
    CLEAN_SQL="$CLEAN_SQL;"

    # 写入输出文件，表之间空行分隔
    echo -e "$CLEAN_SQL\n" >> "$OUTPUT_FILE"
done

echo "所有表建表语句已输出到: $OUTPUT_FILE"
