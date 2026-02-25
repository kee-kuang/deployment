### K8s 部署Nacos



### 安装Nfs

```
服务器都需要执行：
yum install -y nfs-utils
配置nfs服务端：
然后我们需要在nfs的主服务器暴露一个 /data/nfs/mysql 目录，我们需要修改 /etc/exports 配置文件，需要将这一行加在里面：
mkdir -p /data/nfs/mysql
cat >> /etc/exports << EOF
/data/nfs/mysql *(rw,sync,no_root_squash)
EOF
启动nfs服务，只需要在nfs服务器上执行
systemctl enable --now nfs-server
执行这行命令，看目录是否暴露：
showmount -e nfs服务器地址


```

### 创建命名空间

```
apiVersion: v1
kind: Namespace
metadata:
  name: deploy
spec: {}
status: {}

```



### 创建pv 

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: deploy-mysql-nfs-pv # pv的名字
  namespace: deploy # 这里为命名空间的名字
spec:
  capacity:
    storage: 1Gi # 申请的硬盘大小为1GB，可修改
  accessModes:
    - ReadWriteMany # 权限为多节点读写
  nfs:
    # 注意修改nfs服务器地址
    server: 10.0.1.212
    # 注意修改目录的地址
    path: /data/nfs/mysql
  storageClassName: "nfs" # 存储类型选择nfs

```



### 创建pvc 

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: deploy-mysql-nfs-pvc # 为pvc取一个好听的名字
  namespace: deploy # 命名空间名字
spec:
  accessModes:
    - ReadWriteMany # 权限为多节点读写
  storageClassName: "nfs" # 存储类型为nfs
  resources:
    requests:
      storage: 1Gi # 申请大小容量为1GB
  volumeName: deploy-mysql-nfs-pv # 绑定的pv名字

```



#### 1. 部署Mysql

```
创建mysql的root密码的secret
kubectl create secret generic mysql-password --from-literal=mysql_root_password=mysql的root密码 -n 命名空间 --dry-run=client -o=yaml
```

![image-20240714141457890](C:\Users\kuang\AppData\Roaming\Typora\typora-user-images\image-20240714141457890.png)

```yml

部署文件：deploy-mysql.yaml

apiVersion: v1
kind: Namespace
metadata:
  name: deploy
spec: {}
status: {}

---

apiVersion: v1
kind: PersistentVolume
metadata:
  name: deploy-mysql-nfs-pv
  namespace: deploy
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: 10.0.1.212
    path: /data/nfs/nacos-mysql
  storageClassName: "nfs"

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: deploy-mysql-nfs-pvc
  namespace: deploy
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: "nfs"
  resources:
    requests:
      storage: 1Gi
  volumeName: deploy-mysql-nfs-pv

---

apiVersion: v1
data:
  mysql_root_password: root
kind: Secret
metadata:
  name: mysql-password
  namespace: deploy

---

apiVersion: v1
kind: Service
metadata:
  name: deploy-mysql-svc
  namespace: deploy
  labels:
    app: mysql
spec:
  ports:
  - port: 3306
    name: mysql
    targetPort: 3306
    nodePort: 30306
  selector:
    app: mysql
  type: NodePort
  sessionAffinity: ClientIP

---

apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: deploy-mysql
  namespace: deploy
spec:
  selector:
    matchLabels:
      app: mysql
  serviceName: "deploy-mysql-svc"
  replicas: 1
  template:
    metadata:
      labels:
        app: mysql
    spec:
      terminationGracePeriodSeconds: 10
      containers:
      - args:
        - --character-set-server=utf8mb4
        - --collation-server=utf8mb4_unicode_ci
        - --lower_case_table_names=1
        - --default-time_zone=+8:00
        name: mysql
        image: registry.cn-guangzhou.aliyuncs.com/keee/nacos-mysql:2.0.4
        ports:
        - containerPort: 3306
          name: mysql
        volumeMounts:
        - name: mysql-data
          mountPath: /var/lib/mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              key: mysql_root_password
              name: mysql-password
      volumes:
      - name: mysql-data
        persistentVolumeClaim:
          claimName: deploy-mysql-nfs-pvc
          
 #执行命令部署
 kubectl apply -f deploy-mysql.yaml
 # 查看结果
 kubectl get all -o wide -n deploy 

```



#### 2. 部署Nacos

```
部署文件：deploy-nacos.yaml

apiVersion: v1
data:
  jvm-xmn: 128m
  jvm-xms: 256m
  jvm-xmx: 256m
  mode: cluster
  mysql-database-num: "1"
  mysql-service-db-name: nacos_config
  mysql-service-db-param: characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useSSL=false
  mysql-service-host: deploy-mysql-0.deploy-mysql-svc.deploy.svc.cluster.local
  mysql-service-port: "3306"
  mysql-service-user: root
  nacos-servers: deploy-nacos-0.deploy-nacos-svc.deploy.svc.cluster.local:8848
    deploy-nacos-1.deploy-nacos-svc.deploy.svc.cluster.local:8848
  spring-datasource-platform: mysql
kind: ConfigMap
metadata:
  name: nacos-deploy-config
  namespace: deploy

---

apiVersion: v1
kind: Service
metadata:
  name: deploy-nacos-svc
  namespace: deploy
  labels:
    app: nacos
spec:
  ports:
  - port: 8848
    name: nacos
    targetPort: 8848
    nodePort: 30848
  selector:
    app: nacos
  type: NodePort
  sessionAffinity: ClientIP

---

apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: deploy-nacos
  namespace: deploy
spec:
  selector:
    matchLabels:
      app: nacos
  serviceName: "deploy-nacos-svc"
  replicas: 2
  template:
    metadata:
      labels:
        app: nacos
    spec:
      terminationGracePeriodSeconds: 10
      containers:
      - name: nacos
        image: registry.cn-guangzhou.aliyuncs.com/keee/nacos-server:v2.0.4
        ports:
        - containerPort: 8848
          name: nacos
        env:
        - name: JVM_XMN
          valueFrom:
            configMapKeyRef:
              key: jvm-xmn
              name: nacos-deploy-config
        - name: JVM_XMS
          valueFrom:
            configMapKeyRef:
              key: jvm-xms
              name: nacos-deploy-config
        - name: JVM_XMX
          valueFrom:
            configMapKeyRef:
              key: jvm-xmx
              name: nacos-deploy-config
        - name: MODE
          valueFrom:
            configMapKeyRef:
              key: mode
              name: nacos-deploy-config
        - name: MYSQL_DATABASE_NUM
          valueFrom:
            configMapKeyRef:
              key: mysql-database-num
              name: nacos-deploy-config
        - name: MYSQL_SERVICE_DB_NAME
          valueFrom:
            configMapKeyRef:
              key: mysql-service-db-name
              name: nacos-deploy-config
        - name: MYSQL_SERVICE_DB_PARAM
          valueFrom:
            configMapKeyRef:
              key: mysql-service-db-param
              name: nacos-deploy-config
        - name: MYSQL_SERVICE_HOST
          valueFrom:
            configMapKeyRef:
              key: mysql-service-host
              name: nacos-deploy-config
        - name: MYSQL_SERVICE_PASSWORD
          valueFrom:
            secretKeyRef:
              key: mysql_root_password
              name: mysql-password
        - name: MYSQL_SERVICE_PORT
          valueFrom:
            configMapKeyRef:
              key: mysql-service-port
              name: nacos-deploy-config
        - name: MYSQL_SERVICE_USER
          valueFrom:
            configMapKeyRef:
              key: mysql-service-user
              name: nacos-deploy-config
        - name: NACOS_SERVERS
          valueFrom:
            configMapKeyRef:
              key: nacos-servers
              name: nacos-deploy-config
        - name: SPRING_DATASOURCE_PLATFORM
          valueFrom:
            configMapKeyRef:
              key: spring-datasource-platform
              name: nacos-deploy-config


#执行部署命令
kubectl apply -f deploy-nacos.yaml

```

