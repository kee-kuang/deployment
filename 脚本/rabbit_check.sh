#/bash/bin

#项目名称
PROFJECT_NAME="中捷生产环境"

#钉钉地址
webhook_url="https://oapi.dingtalk.com/robot/send?access_token=1fd1ff15079a81a28d28fe48694c5d0f81df97df013e6ba1834d647d7aa861db"

#RabbitMQ配置
rabbitmq_host="10.121.151.128"
rabbitmq_port="5673"
rabbitmq_user="erAs"
rabbitmq_pass="N7cxp2gdvJvhdvhW"
rabbitmq_queue_threshold="500"

#获取当前时间
time=$(date "+%Y-%m-%d %H:%M:%S")


# 检查 RabbitMQ 节点状态
rabbitmq_node_status=$(rabbitmqctl status | grep "Status of node" | awk '{print $5}')
if [ "$rabbitmq_node_status" != "running" ]; then
    message="[${PROJECT_NAME} ${time}][RabbitMQ] Node status is not running! (current status: $rabbitmq_node_status)"
else
    message="[${PROJECT_NAME} ${time}][RabbitMQ]current status: $rabbitmq_node_status"
    curl -s -H "Content-Type: application/json" -X POST -d "{\"msgtype\": \"text\", \"text\": {\"content\": \"$message\"}}" $webhook_url > /dev/null
fi


# 检查 RabbitMQ 队列长度是否正常
rabbitmq_queue_length=$(rabbitmqctl list_queues | awk '{print $2}' | awk '{s+=$1} END {print s}')
if [ "$rabbitmq_queue_length" -gt "$rabbitmq_queue_threshold" ]; then
    message="[${PROJECT_NAME} ${time}][RabbitMQ] Length of queues has exceeded the threshold! (current length: $rabbitmq_queue_length, threshold: $rabbitmq_queue_threshold)"
else
    message="[${PROJECT_NAME} ${time}][RabbitMQ] current length: $rabbitmq_queue_length, threshold: $rabbitmq_queue_threshold"
    curl -s -H "Content-Type: application/json" -X POST -d "{\"msgtype\": \"text\", \"text\": {\"content\": \"$message\"}}" $webhook_url > /dev/null
fi

