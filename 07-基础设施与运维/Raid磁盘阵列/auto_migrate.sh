#!/bin/bash

# 设置高峰时段（01点~09点）
PEAK_START=1
PEAK_END=9

# 钉钉 Webhook URL
DINGTALK_WEBHOOK="https://oapi.dingtalk.com/robot/send?access_token=a048d5d6506999cf4ac615699976a4a16e0fcfe8b1e837d5ff7d8ffba0464105"

# Prometheus Pushgateway URL
PUSHGATEWAY_URL="http://192.168.100.249:9091/metrics/job/raid_migration"

# 无限循环执行
while true; do
    CURRENT_HOUR=$(date +'%H')
    CURRENT_HOUR=$((10#$CURRENT_HOUR))  

    MIGRATE_STATUS=$(./storcli64 /c0/v1 show migrate)

    if ! echo "$MIGRATE_STATUS" | grep -iq "In Progress"; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') 未检测到RAID迁移任务，跳过速率调整与推送。"
        sleep 300
        continue
    fi

    MIGRATE_PROGRESS=$(echo "$MIGRATE_STATUS" | awk '/^[[:space:]]*[0-9]+[[:space:]]+Migrate/ {print $3}')
    MIGRATE_ESTIMATED_TIME=$(echo "$MIGRATE_STATUS" | awk '/^[[:space:]]*[0-9]+[[:space:]]+Migrate/ {for(i=5;i<=NF;i++) printf $i " "; print ""}')

    RATE=30
    if [[ $CURRENT_HOUR -ge $PEAK_START && $CURRENT_HOUR -lt $PEAK_END ]]; then
        ./storcli64 /c0 set migraterate=50
        RATE=50
    else
        ./storcli64 /c0 set migraterate=70
        RATE=70
    fi

    LOG_TIME=$(date "+%Y-%m-%d %H:%M:%S")
    MESSAGE="[$LOG_TIME] 当前RAID迁移进度：${MIGRATE_PROGRESS}%，预计剩余时间：${MIGRATE_ESTIMATED_TIME}，当前迁移速率：${RATE}%"

    # 推送钉钉
    curl -s -X POST "$DINGTALK_WEBHOOK" \
        -H 'Content-Type: application/json' \
        -d "{
            \"msgtype\": \"text\",
            \"text\": {
                \"content\": \"$MESSAGE\"
            }
        }" > /dev/null

    # 推送到 Pushgateway
    cat <<EOF | curl --data-binary @- "$PUSHGATEWAY_URL"
# raid_migration_progress 类型指标
raid_migration_progress $MIGRATE_PROGRESS
# raid_migration_rate类型指标
raid_migration_rate $RATE
EOF

    # 输出日志
    echo "$MESSAGE"
    echo "------------------------------------------"

    sleep 300
done
