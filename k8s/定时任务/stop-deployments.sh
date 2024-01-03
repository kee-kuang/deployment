#！/bin/bash

#scale down all deployments to 0 replicas
#kubectl get deployments -n zhongjie -l k8s.kuboard.cn/layer=web --output=name | xargs -I {} kubectl scale {} --replicas=0



kubectl get deployments -n zhongjie -l k8s.kuboard.cn/layer=web --output=name | xargs -I {} kubectl scale deployment --replicas=0


kubectl get deployments -n gaohuaxue-test-v2 -l k8s.kuboard.cn/layer=web --output=name | xargs -I {} kubectl scale deployment --replicas=0


kubectl scale deployment -n zhongjie -l k8s.kuboard.cn/layer=web --replicas=0