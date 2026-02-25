#!/bin/bash
  
# 检测 Elasticsearch 是否在线
health_status=$(curl -u "elastic:'7YkwnlV#[#bh4sP" http://10.121.151.46:9202/_cat/health | awk '{print $4}' | xargs -I {} echo {})

if [ "$health_status" != "green" ]; then
    echo "$(date +'%Y-%m-%d-%H:%M:%S') Bad"
    systemctl restart elasticsearch

    # 等待一段时间再次检查状态
    sleep 10s

    # 循环检查 Elasticsearch 状态
    while true; do
        if [ "$health_status" == "green" ]; then
            echo "$(date +'%Y-%m-%d-%H:%M:%S') Good" > /dev/null
            break
        else
            echo "$(date +'%Y-%m-%d-%H:%M:%S') Still Bad"
            sleep 15s
            systemctl restart elasticsearch
        fi
    done
else
    echo "$(date +'%Y-%m-%d-%H:%M:%S') Good" > /dev/null
fi