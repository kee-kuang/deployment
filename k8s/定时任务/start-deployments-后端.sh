#!/bin/bash

# 定义命名空间
NAMESPACE="zhongjie"

# 定义部署名称和对应的副本数
declare -A SERVICES=(
    ["after-sale-service"]=2
    ["gateway-service"]=3
    ["logistics-service"]=2
    ["merchant-member-service"]=2
    ["message-service"]=2
    ["open-api-service"]=3
    ["order-service"]=3
    ["product-service"]=3
)

# 设置指定副本数的函数
set_replicas() {
    deployment="$1"
    replicas="$2"
    kubectl scale deployment "$deployment" --replicas="$replicas" -n "$NAMESPACE"
}

# 遍历 SERVICES 数组，设置副本数
for service in "${!SERVICES[@]}"; do
    set_replicas "$service" "${SERVICES[$service]}"
done

# 设置其他部署的副本数
kubectl get deployments -n "$NAMESPACE" -o custom-columns=:metadata.name --no-headers | while read -r deployment; do
    set_replicas