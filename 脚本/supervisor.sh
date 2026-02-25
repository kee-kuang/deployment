#!/bin/bash


dingding_webhook_url="https://oapi.dingtalk.com/robot/send?access_token=8f7b08286c8b8ebfc5ce3048b69affe943a2de57aba9a969e88db88322da6b96"


secret="SECd5877494eeb5ef8ed0a4645c2d331af25126ad78110d2f395812c437570c686f"


timestamp=$(date +%s)
nonce=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 10)
signature=$(echo -n "${timestamp}\n${nonce}\n${secret}" | openssl dgst -sha256 -hmac "${secret}" -binary | base64)


list=$(supervisorctl status | grep "FATAL" | awk -F" " '{print$1}')
date=$(date +'%Y-%m-%d')


if [ -n "$list" ]; then
  for process in $list; do
    echo "$date 重启失败的进程:$process"
    supervisorctl restart $process

    message="{\"msgtype\":\"text\",\"text\":{\"content\":\"$date 重启失败的进程:$process\"}}"
    curl $dingding_webhook_url -H 'Content-Type: application/json' -d "$message" -H "timestamp: $timestamp" -H "nonce:$nonce" -H "sign: $signature"
  done
else
  message="{\"msgtype\":\"text\",\"text\":{\"content\":\"$date 进程正常:$process\"}}"
  curl $dingding_webhook_url -H 'Content-Type: application/json' -d "$message" -H "timestamp: $timestamp" -H "nonce:$nonce" -H "sign: $signature"
  echo "$date 所有进程运行正常。" > /dev/null
fi
