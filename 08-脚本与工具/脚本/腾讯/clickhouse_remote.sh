#!/bin/bash

SRC_HOST=47.107.173.188
SRC_PORT=9300
SRC_USER=yuetou
SRC_PASS='1qJL8lCl7Gu@C-Y'

DST_HOST=127.0.0.1
DST_PORT=9000
DST_USER=yuetou
DST_PASS='pWZIGBCV(SaZV2Zdi'

LOG_FILE="./clickhouse_sync.log"
BATCH_SIZE=50000
SYNC_INTERVAL=300  # 每 5 分钟增量同步一次

while true; do
    echo "增量同步开始: $(date '+%Y-%m-%d %H:%M:%S')"
    
    DATABASES=$(clickhouse-client --host $SRC_HOST --port $SRC_PORT --user $SRC_USER --password "$SRC_PASS" \
                --query="SHOW DATABASES" | grep -Ev '^(system|information_schema|INFORMATION_SCHEMA)$')
    
    for DB in $DATABASES; do
        TABLES=$(clickhouse-client --host $SRC_HOST --port $SRC_PORT --user $SRC_USER --password "$SRC_PASS" \
                 --query="SHOW TABLES FROM \`$DB\`")
        
        for TBL in $TABLES; do
            LAST_SYNC=$(grep "^$DB.$TBL" $LOG_FILE 2>/dev/null | awk '{print $2}')
            [ -z "$LAST_SYNC" ] && LAST_SYNC='1970-01-01 00:00:00'

            HAS_UPDATED=$(clickhouse-client --host $SRC_HOST --port $SRC_PORT --user $SRC_USER --password "$SRC_PASS" \
                          --query="DESCRIBE TABLE \`$DB\`.\`$TBL\`" | awk '{print $1}' | grep -w 'updated_at' || true)
            
            [ -z "$HAS_UPDATED" ] && continue  # 没有 updated_at 字段就跳过

            TOTAL_ROWS=$(clickhouse-client --host $SRC_HOST --port $SRC_PORT --user $SRC_USER --password "$SRC_PASS" \
                         --query="SELECT count() FROM \`$DB\`.\`$TBL\` WHERE updated_at > '$LAST_SYNC'")
            
            OFFSET=0
            while [ "$OFFSET" -lt "$TOTAL_ROWS" ]; do
                END=$((OFFSET + BATCH_SIZE - 1))
                clickhouse-client --host $DST_HOST --port $DST_PORT --user $DST_USER --password "$DST_PASS" --query="
                    INSERT INTO \`$DB\`.\`$TBL\`
                    SELECT * FROM remote('$SRC_HOST:$SRC_PORT', '$DB', '$TBL', '$SRC_USER', '$SRC_PASS')
                    WHERE updated_at > '$LAST_SYNC'
                    LIMIT $BATCH_SIZE OFFSET $OFFSET
                "
                OFFSET=$((OFFSET + BATCH_SIZE))
            done

            MAX_UPDATED=$(clickhouse-client --host $SRC_HOST --port $SRC_PORT --user $SRC_USER --password "$SRC_PASS" \
                          --query="SELECT max(updated_at) FROM \`$DB\`.\`$TBL\`")
            
            grep -v "^$DB.$TBL" $LOG_FILE 2>/dev/null > "$LOG_FILE.tmp" || true
            echo "$DB.$TBL $MAX_UPDATED" >> "$LOG_FILE.tmp"
            mv "$LOG_FILE.tmp" "$LOG_FILE"
        done
    done

    echo "增量同步结束: $(date '+%Y-%m-%d %H:%M:%S')"
    sleep $SYNC_INTERVAL
done
