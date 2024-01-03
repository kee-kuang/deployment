#!/bin/bash
#项目名称
PROJECT="中捷生产环境"

#设置Nacos地址、端口号、命名空间、分组名称、用户名、密码
NACOS_HOST="10.121.151.128"
NACOS_PORT="8851"
NAMESPACE="86986e56-9ef3-4c9e-a398-4cc54f78354e"
GROUPNAME="v1.0.0"
NACOS_USERNAME="nacos"
NACOS_PASSWORD="N7cxp2gdvJvhdvhW"

#设置要监控的服务列表、命名空间、分组
SERVICE_LIST=("after-sale-service" "contract-service" "enhance-service" "file-service" "gateway-service" "logistics-service" "marketing-service" "merchant-member-service" "message-service" "open-api-service" "order-service" "pay-service" "platform-manage-service" "platform-template-service" "product-service" "purchase-service" "report-service" "rule-engine-service" "scheduler-service" "search-service" "settle-accounts-service" "sms-service" "system-service" "transaction-service" "workflow-service")

#企业微信机器人
WECHAT_WEBHOOK_URL="https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=fba13b81-d1fe-42cd-873e-8d7481284ce1"

#获取Token
TOKEN=$(curl -s -X POST "http://${NACOS_HOST}:${NACOS_PORT}/nacos/v1/auth/login" -d "username=${NACOS_USERNAME}&password=${NACOS_PASSWORD}" | jq -r '.accessToken')

for SERVICE_NAME in "${SERVICE_LIST[@]}"
do
    #调用Nacos API获取服务实例列表
    SERVICE_LIST=$(curl -s "http://${NACOS_HOST}:${NACOS_PORT}/nacos/v1/ns/instance/list?accessToken=${TOKEN}&serviceName=${SERVICE_NAME}&namespaceId=${NAMESPACE}&groupName=${GROUPNAME}" -H "Authorization: bearer ${TOKEN}")

    #获取当前服务实例数量
    INSTANCE_NUM=$(echo $SERVICE_LIST | jq '.["hosts"] | length')

    #如果服务实例数量为0，说明服务已经宕机
    if [[ $INSTANCE_NUM -eq 0 ]]
    then
        echo "Service ${SERVICE_NAME} is down."
        MESSAGE="{\"msgtype\":\"text\",\"at\":{\"isAtAll\":\"true\"},\"text\":{\"content\":\"【${PROJECT}】${SERVICE_NAME} 服务不可用！！！\"}}"
        curl -s -H "Content-Type: application/json" -d "${MESSAGE}" "${WECHAT_WEBHOOK_URL}"
    else
        echo "Service ${SERVICE_NAME} is up with ${INSTANCE_NUM} instances."
    fi
done
