### k8s 节点组件

```
master 组件：

kube-apiserver: 集群的统一入口，各组件的协调者

kube-controller-manager：处理集群中常规的后台任务，负责管理控制器的

kube-scheduler：分配节点的

etcd：分布式键值存储系统。用于保存集群状态的

node组件:

kubelet：kubecyl 是master 在node 节点上的agent ,是管理本机运行容器的生命周期

kube-proxy：在node节点上实现pod 网络代理，维护网络规则和四层负载均衡工作

docker、containerd：容器引擎、运行容器
```

### 部署k8s的方式

```
1.kubeadm
kubeadm 是一个工具，提供kubeadm init 和 kubeadm join 用于快速部署Kubernetes 集群。
部署地址：https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm/
2.二进制
从官方下载发行版的二进制包，手动部署每个组件，组成Kubernetes 集群
下载地址：http://github.com/kubernetes/kubernetes/releases
3. 第三方组件
类似sealos、easzup
```

### Kubeadm 工具功能：

- **Kubeadm init** :初始化一个Master 节点
- **Kubeadm join** : 将工作节点加入集群

* **kubeadm upgrade**: 升级K8s 版本
* **kubeadm token** : 管理Kubeadm join 令牌
* **kubeadm reset**: 清空Kubeadm init 或者 kubeadm join 对主机所做的任何更改 卸载
* **kubeadm version**: 打印kubeadm 版本
* **kubeam alpha**: 预览可用的新功能

### 服务器硬件配置推荐

| 实验环境 | K8smaster/node | 2c2G+            |      |
| -------- | -------------- | ---------------- | ---- |
| 测试环境 | K8s-master     | 2C4G  硬盘20G    |      |
|          | K8s-node       | 4C8G  硬盘20G    |      |
| 生产环境 | K8s-master     | 8c16g  硬盘100G  |      |
|          | K8s-node       | 16c64g  硬盘500G |      |
|          | .....          |                  |      |
|          |                |                  |      |

### 使用kubeadm 快速部署一个k8s集群内

#### 1.1 操作系统初始化配置

```
#关闭防火墙
systemctl stop firewalld

# 关闭swap 
swapoff -a #临时
sed -i 's/.*seap.*/#&/' /etc/fstab

#根据规划设置主机名
hostnamectl set-hostname K8s-master

#在master添加hosts
vim /etc/hosts

#将桥接的ipv4 流量传递到iptables 的链上
cat > /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system #生效

#时间同步
yum -y install ntpdate
ntpdate time.windows.com
```

#### 1.2 安装docker/kubeadm/kubelet [所有节点]

 这里使用Docker 作为容器引擎，可以换成其它的，例如containerd

#### 1.2.1 安装docker

```bash
wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -o /etc/yum.repos.d/docker-ce.repo
yum -y install docker-ce 
systemctl start docker && systemctl enable docker 

# 配置镜像下载加速器
cat > /etc/docekr/deamon.json << EOF
{
  "registry-mirrors": ["https://b9pmyelo.mirror.aliyuncs.com"]
}
EOF

systemctl restart docker
docker info
```

#### 1.2.2 添加阿里云Yum 软件源

```repo
cat > /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
```

#### 1.2.3 安装kubeadm,kubelet和Kubectl

由于版本更新频繁，这里指定版本号部署

```
yum -y install kubeadm-1.21.0 kubelet-1.21.0 kubectl-1.21.0
systemctl enable kubelet
```

