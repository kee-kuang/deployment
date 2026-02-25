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
