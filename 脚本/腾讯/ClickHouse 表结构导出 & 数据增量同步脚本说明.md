# ClickHouse 表结构导出 & 数据增量同步脚本说明

## 1. 批量导出 ClickHouse 表结构

用于从源库导出建表语句，并处理 `COMMENT` 与转义字符，使其可直接在目标库执行。

```bash
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
    # 3. 将 \' 替换为 ''
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
```

------

## 2. ClickHouse 增量同步脚本

支持：

- 多库自动获取
- 根据 `updated_at` 字段做增量同步
- 无 `updated_at` 字段的表做全量同步
- 分批次导入，避免大表一次性占用资源
- 同步日志记录每张表的最大 `updated_at`

```bash
#!/bin/bash
# ClickHouse 增量同步脚本（支持多库、自动避免重复导入）

SRC_HOST=47.107.173.188
SRC_PORT=9300
SRC_USER=yuetou
SRC_PASS='1qJL8lCl7Gu@C-Y'

DST_HOST=127.0.0.1
DST_PORT=9000
DST_USER=yuetou
DST_PASS='pWZIGBCV(SaZV2Zdi'

BATCH_SIZE=50000
LOG_FILE="./clickhouse_sync.log"

echo "同步开始时间: $(date '+%Y-%m-%d %H:%M:%S')"

# 获取源库列表（排除系统库）
DATABASES=$(clickhouse-client --host $SRC_HOST --port $SRC_PORT --user $SRC_USER --password "$SRC_PASS" \
            --query="SHOW DATABASES" | grep -Ev '^(system|information_schema|INFORMATION_SCHEMA)$')

for DB in $DATABASES; do
    echo "== 同步库: $DB =="

    # 获取表列表
    TABLES=$(clickhouse-client --host $SRC_HOST --port $SRC_PORT --user $SRC_USER --password "$SRC_PASS" \
             --query="SHOW TABLES FROM \`$DB\`")

    for TBL in $TABLES; do
        echo "  -> 同步表: $DB.$TBL"

        # 检查目标表是否存在
        TABLE_EXISTS=$(clickhouse-client --host $DST_HOST --port $DST_PORT --user $DST_USER --password "$DST_PASS" \
                       --query="EXISTS \`$DB\`.\`$TBL\`")
        if [ "$TABLE_EXISTS" -eq 0 ]; then
            echo "     -> 目标表不存在，先创建表结构"
            CREATE_SQL=$(clickhouse-client --host $SRC_HOST --port $SRC_PORT --user $SRC_USER --password "$SRC_PASS" \
                         --query="SHOW CREATE TABLE \`$DB\`.\`$TBL\`" | sed 's/^CREATE TABLE/CREATE TABLE IF NOT EXISTS/')
            CREATE_SQL="$CREATE_SQL;"
            clickhouse-client --host $DST_HOST --port $DST_PORT --user $DST_USER --password "$DST_PASS" --multiquery <<< "$CREATE_SQL"
        fi

        # 获取上次同步时间
        LAST_SYNC=$(grep "^$DB.$TBL" $LOG_FILE 2>/dev/null | awk '{print $2}')
        if [ -z "$LAST_SYNC" ]; then
            LAST_SYNC='1970-01-01 00:00:00'
        fi

        # 判断表是否有 updated_at 字段
        HAS_UPDATED=$(clickhouse-client --host $SRC_HOST --port $SRC_PORT --user $SRC_USER --password "$SRC_PASS" \
                      --query="DESCRIBE TABLE \`$DB\`.\`$TBL\`" | awk '{print $1}' | grep -w 'updated_at' || true)

        if [ -n "$HAS_UPDATED" ]; then
            echo "     -> 增量同步 (updated_at > '$LAST_SYNC')"
            CONDITION="WHERE updated_at > '$LAST_SYNC'"
        else
            echo "     -> 全量同步 (表无 updated_at)"
            CONDITION=""
        fi

        # 获取需要同步的行数
        TOTAL_ROWS=$(clickhouse-client --host $SRC_HOST --port $SRC_PORT --user $SRC_USER --password "$SRC_PASS" \
                     --query="SELECT count() FROM \`$DB\`.\`$TBL\` $CONDITION")
        echo "     -> 需要同步行数: $TOTAL_ROWS"

        OFFSET=0
        while [ "$OFFSET" -lt "$TOTAL_ROWS" ]; do
            END=$((OFFSET + BATCH_SIZE - 1))
            echo "     -> 同步 $OFFSET ~ $END"

            clickhouse-client --host $DST_HOST --port $DST_PORT --user $DST_USER --password "$DST_PASS" --query="
                INSERT INTO \`$DB\`.\`$TBL\`
                SELECT * FROM remote('$SRC_HOST:$SRC_PORT', '$DB', '$TBL', '$SRC_USER', '$SRC_PASS')
                $CONDITION
                LIMIT $BATCH_SIZE OFFSET $OFFSET
            "

            OFFSET=$((OFFSET + BATCH_SIZE))
        done

        # 更新同步日志
        if [ -n "$HAS_UPDATED" ]; then
            MAX_UPDATED=$(clickhouse-client --host $SRC_HOST --port $SRC_PORT --user $SRC_USER --password "$SRC_PASS" \
                          --query="SELECT max(updated_at) FROM \`$DB\`.\`$TBL\`")
            grep -v "^$DB.$TBL" $LOG_FILE 2>/dev/null > "$LOG_FILE.tmp" || true
            echo "$DB.$TBL $MAX_UPDATED" >> "$LOG_FILE.tmp"
            mv "$LOG_FILE.tmp" "$LOG_FILE"
        fi

    done

done

echo "同步完成: $(date '+%Y-%m-%d %H:%M:%S')"
```

------

### 使用说明

1. **建表脚本**

   ```bash
   bash export_create_tables.sh
   ```

   - 会生成 `cid_create_tables.sql`，直接在目标库导入即可。

2. **增量同步脚本**

   ```bash
   bash clickhouse_sync.sh
   ```

   - 自动处理多库、多表
   - 有 `updated_at` 的表做增量同步
   - 无 `updated_at` 的表做全量同步
   - 同步日志记录在 `clickhouse_sync.log`

3. **注意事项**

   - 确保目标库表与源库表的主键、MergeTree 引擎一致。
   - 对于无 `updated_at` 的大表，全量同步可能耗时较长，可在低峰期执行。
   - 脚本支持批量同步，`BATCH_SIZE` 可根据实际情况调整。