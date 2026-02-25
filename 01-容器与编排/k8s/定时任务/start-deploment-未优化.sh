#设定服务启动副本数
kubectl get deployments -n zhongjie --output=name | xargs -I {} kubectl scale {} --replicas=1
kubectl get deployments -n zhongjie -o custom-columns=:metadata.name --no-headers | xargs -I {} kubectl scale deployment {} --replicas=1 -n zhongjie



#单独设定服务启动指定副本数
kubectl scale after-sale-service --replicas=2
kubectl scale gateway-service --replicas=3
kubectl scale logistics-service --replicas=2
kubectl scale merchant-member-service --replicas=2
kubectl scale message-service --replicas=2
kubectl scale open-api-service --replicas=3
kubectl scale order-service --replicas=3
kubectl scale product-service --replicas=3