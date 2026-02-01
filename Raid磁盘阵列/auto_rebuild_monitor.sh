#!/bin/bash

# 配置参数
CONTROLLER=0
VD_INDEX=1
TEXTFILE_DIR="/var/lib/node_exporter/textfile"
TEXTFILE="${TEXTFILE_DIR}/rebuild_metrics.prom"
DINGDING_WEBHOOK="https://oapi.dingtalk.com/robot/send?access_token=XXXX"
HIGH_LOAD_TIME="00-09"  # 白天时间段
LOW_RATE=100
HIGH_RATE=500

# 获取当前小时
HOUR=$(date +%H)
PROGRESS=0
REBUILD_STATUS="idle"
CURRENT_RATE=0

# 获取重建信息
REBUILD_OUTPUT=$(./storcli64 /c${CONTROLLER}/v${VD_INDEX} show rebuild J)

if echo "$REBUILD_OUTPUT" | grep -q "\"Status\".*in progress"; then
  REBUILD_STATUS="rebuilding"
  PROGRESS=$(echo "$REBUILD_OUTPUT" | jq -r '.Controllers[0].Response[].Progress')
  CURRENT_RATE=$(echo "$REBUILD_OUTPUT" | jq -r '.Controllers[0].Response[].Rate' | sed 's/[^0-9]//g')
fi

# 判断当前是否为高峰期
if (( HOUR >= ${HIGH_LOAD_TIME%-*} && HOUR <= ${HIGH_LOAD_TIME#*-} )); then
  TARGET_RATE=$LOW_RATE
else
  TARGET_RATE=$HIGH_RATE
fi

# 如果状态为 rebuilding，则设置新速率
if [[ "$REBUILD_STATUS" == "rebuilding" ]]; then
  ./storcli64 /c${CONTROLLER} set rebuildrate=${TARGET_RATE} > /dev/null

  # 钉钉通知
  curl -s -X POST -H "Content-Type: application/json" -d "{
    \"msgtype\": \"text\",
    \"text\": {
      \"content\": \"RAID重建状态：$REBUILD_STATUS，进度：$PROGRESS%，当前速率：${TARGET_RATE}KB/s（自动调整）\"
    }
  }" "$DINGDING_WEBHOOK"
fi

# 输出到 textfile
cat > "$TEXTFILE" <<EOF
raid_rebuild_status{controller="${CONTROLLER}",vd="${VD_INDEX}"} $( [[ "$REBUILD_STATUS" == "rebuilding" ]] && echo 1 || echo 0 )
raid_rebuild_progress{controller="${CONTROLLER}",vd="${VD_INDEX}"} ${PROGRESS}
raid_rebuild_rate_kb{controller="${CONTROLLER}"} ${TARGET_RATE}
EOF
