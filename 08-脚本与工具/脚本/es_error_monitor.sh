#!/bin/bash

# Elasticsearch配置
ES_HOST="localhost"
ES_PORT="9200"
ES_INDEX_PREFIX="logstash-"
ES_INDEX_LIST=("index1" "index2" "index3")
ES_QUERY='{
  "query": {
    "bool": {
      "must": [
        {"match": {"log_level": "ERROR"}},
        {"range": {"@timestamp": {"gte": "now-5m"}}}
      ]
    }
  },
  "size": 10,
  "sort": [
    {
      "@timestamp": {
        "order": "desc"
      }
    }
  ]
}'

# 钉钉机器人配置
DINGTALK_ACCESS_TOKEN="YOUR_DINGTALK_ACCESS_TOKEN"
DINGTALK_SECRET="YOUR_DINGTALK_SECRET"

# 遍历 Elasticsearch 索引
for index in "${ES_INDEX_LIST[@]}"
do
  # 构建 Elasticsearch 索引名称
  ES_INDEX="$ES_INDEX_PREFIX$index"

  # 搜索 Elasticsearch 错误日志
  RESULT=$(curl -s -XGET "http://$ES_HOST:$ES_PORT/$ES_INDEX/_search" \
      -H 'Content-Type: application/json' \
      -d "$ES_QUERY")

  # 判断是否有错误日志
  if [[ $RESULT == *'"total":0,'* ]]; then
    echo "No errors found in Elasticsearch index $index."
  else
    # 获取错误日志数量
    ERROR_COUNT=$(echo $RESULT | jq '.hits.total.value')

    # 获取错误日志信息
    ERROR_MESSAGES=$(echo $RESULT | jq -r '.hits.hits[].source.message' | sed 's/"/\\"/g')

    # 构造钉钉消息体
    MESSAGE=$(cat <<EOF
{
  "msgtype": "text",
  "text": {
    "content": "在 Elasticsearch 索引 $index 中发现 $ERROR_COUNT 条错误日志，请及时处理！\n\n错误信息：\n$ERROR_MESSAGES"
  }
}
EOF
    )

    # 发送钉钉消息
    TIMESTAMP=$(date +%s%N)
    STRING_TO_SIGN="$TIMESTAMP\n$DINGTALK_SECRET"
    SIGN=$(echo -n $STRING_TO_SIGN | openssl dgst -sha256 -hmac $DINGTALK_SECRET -binary | base64)
    curl -s -XPOST "https://oapi.dingtalk.com/robot/send?access_token=$DINGTALK_ACCESS_TOKEN&timestamp=$TIMESTAMP&sign=$SIGN" \
      -H 'Content-Type: application/json' \
      -d "$MESSAGE"
  fi
done
