#/bin/bash

#项目名称
PROJECT_NAME="中捷生产环境"

#钉钉机器人
ROOT_url="https://oapi.dingtalk.com/robot/send?access_token=1fd1ff15079a81a28d28fe48694c5d0f81df97df013e6ba1834d647d7aa861db"

#Redis 相关配置
REDIS_HOST="10.121.151.132"
REDIS_PORT="6390"
REDIS_PASSWORD="N7cxp2gdvJvhdvhW"
redis_max_connections="500"

#获取当前的时间
time=$(date "+%Y-%m"-%d %H:%M:%S)

#检查Redis 连接数
redis_current_connections=$(redis-cli -h $redis_host -p $redis_port -a $redis_pass info clients | grep "connected_clients" | awk -F':' '{print $2}' | tr -d '\r')
if [ "$redis_current_connections" -gt "$redis_max_connections" ]; then
#发送钉钉消息
    message="[${PROJECT_NAME} ${time}][Redis] Number of connections has exceeded the maximum value! (current connections: $redis_current_connections, max connections: $redis_max_connections)"
else
    message="[${PROJECT_NAME} ${time}][Redis] (current connections: $redis_current_connections, max connections: $redis_max_connections)"
    curl -s -H "Content-Type: application/json" -X POST -d "{\"msgtype\": \"text\", \"text\": {\"content\": \"$message\"}}" $webhook_url  


