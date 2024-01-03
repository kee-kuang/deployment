#!/bin/bash
#项目名称
PROJECT_NAME="中捷生产环境"
# 钉钉机器人 webhook URL
webhook_url="https://oapi.dingtalk.com/robot/send?access_token=1fd1ff15079a81a28d28fe48694c5d0f81df97df013e6ba1834d647d7aa861db"

# 检查节点状态
node_status=$(kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name} {.status.conditions[?(@.type=="Ready")].status}{"\n"}{end}')
echo "Node Status:"
echo "$node_status"

# 检查 Pod 状态
pod_status=$(kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{.metadata.namespace} {.metadata.name} {.status.phase}{"\n"}{end}')
echo "Pod Status:"
echo "$pod_status"

# 检查持久卷状态
pv_status=$(kubectl get pv -o jsonpath='{range .items[*]}{.metadata.name} {.status.phase}{"\n"}{end}')
echo "Persistent Volume Status:"
echo "$pv_status"

# 检查节点资源使用情况
node_resources=$(kubectl top nodes)
echo "Node Resource Usage:"
echo "$node_resources"

# 检查节点通信是否正常
node_communication=$(kubectl get nodes -o wide)
echo "Node Communication:"
echo "$node_communication"

# 发送钉钉告警
timestamp=$(date +"%Y-%m-%d %H:%M:%S")
message="[${PROJECT_NAME}][K8s Inspection] $timestamp\nNode Status:\n$node_status\n\nPod Status:\n$pod_status\n\nPersistent Volume Status:\n$pv_status\n\nNode Resource Usage:\n$node_resources\n\nNode Communication:\n$node_communication"
curl -H "Content-Type: application/json" -d "{\"msgtype\": \"text\", \"text\": {\"content\": \"$message\"}}" $webhook_url

