# 通过使用sealos 部署Kubernetes 集群

## Sealos 介绍

Sealos是一款为Kubernetes集群部署而生的高效工具，通常用于各种生产环境中。使用Sealos可以帮助你在Kubernetes中快速部署各种应用和服务。Sealos支持以下特点和功能：

1、基于Kubernetes的高可用性和容错机制。

2、快速、可靠、高效的部署模式。

3、提供完善的应用配置管理和错误监控机制，保证了集群的健康运行。

4、友好的用户界面和简单易用的命令行工具。

5、多平台支持，即使在虚拟化环境中也可以运行。

**相关github地址：https://github.com/labring/sealos/tree/release-v3.3#readme**

## 注意事项：
ssh 可以访问各安装节点
各节点主机名不相同，并满足kubernetes的主机名要求。
各节点时间同步
网卡名称如果是不常见的，建议修改成规范的网卡名称， 如(eth.|en.|em.*)
kubernetes1.20+ 使用containerd作为cri. 不需要用户安装docker/containerd. sealos会安装1.3.9版本containerd。
kubernetes1.19及以下 使用docker作为cri。 也不需要用户安装docker。 sealos会安装1.19.03版本docker
网络和 DNS 要求：

确保 /etc/resolv.conf 中的 DNS 地址可用。否则，可能会导致群集中coredns异常。
如果使用阿里云/华为云主机部署。 默认的pod网段会和阿里云的dns网段冲突， 建议自定义修改pod网段, 在init的时候指定--podcidr 来修改。
sealos 默认会关闭防火墙， 如果需要打开防火墙， 建议手动放行相关的端口。


## 下载Sealos

```
# 下载并安装sealos
# wget -c https://sealyun-home.oss-cn-beijing.aliyuncs.com/sealos/latest/sealos && \
    chmod +x sealos && mv sealos /usr/bin
# 下载Kube 资源包
# wget -c https://sealyun.oss-cn-beijing.aliyuncs.com/05a3db657821277f5f3b92d834bbaf98-v1.22.0/kube1.22.0.tar.gz
# 安装一个三master的kubernetes集群
# sealos init --passwd '123456' \
	--master 192.168.0.2  --master 192.168.0.3  --master 192.168.0.4  \
	--node 192.168.0.5 \
	--pkg-url /root/kube1.22.0.tar.gz \
	--version v1.22.0
# 检查安装是否成功
# kubectl get node -owide
```

| 参数名  | 含义                                                         | 示例                    |
| ------- | ------------------------------------------------------------ | ----------------------- |
| passwd  | 服务器密码                                                   | 123456                  |
| master  | k8s master节点IP地址                                         | 192.168.0.2             |
| node    | k8s node节点IP地址                                           | 192.168.0.3             |
| pkg-url | 离线资源包地址，支持下载到本地，或者一个远程地址             | /root/kube1.22.0.tar.gz |
| version | [资源包](https://www.sealyun.com/goodsDetail?type=cloud_kernel&name=kubernetes)对应的版本 | v1.22.0                 |

> 增加master

```
🐳 → sealos join --master 192.168.0.6 --master 192.168.0.7
🐳 → sealos join --master 192.168.0.6-192.168.0.9  # 或者多个连续IP
```



> 增加node

```
🐳 → sealos join --node 192.168.0.6 --node 192.168.0.7
🐳 → sealos join --node 192.168.0.6-192.168.0.9  # 或者多个连续IP
```



> 删除指定master节点

```
🐳 → sealos clean --master 192.168.0.6 --master 192.168.0.7
🐳 → sealos clean --master 192.168.0.6-192.168.0.9  # 或者多个连续IP
```



> 删除指定node节点

```
🐳 → sealos clean --node 192.168.0.6 --node 192.168.0.7
🐳 → sealos clean --node 192.168.0.6-192.168.0.9  # 或者多个连续IP
```



> 清理集群

```
🐳 → sealos clean --all
```

本地备份etcd 数据

本地备份, 默认保存在`/opt/sealos/ectd-backup`这个目录， 默认名称为`sanpshot`

```
sealos etcd save
```

本地备份并复制到各master节点。增加--docker参数， 默认在生成的文件下添加当前的uinx时间戳,然后复制到各master节点.

# 在所有的master节点上备份数据
sealos etcd save --docker
1
2

备份上传到阿里云oss
备份上传至oss，首次执行带命令行或者编辑~/.sealos/config.yaml

# 备份上传到阿里云oss
## 需要自行指定oss的ak参数
sealos etcd save --docker \
    --aliId youraliyunkeyid \
    --aliKey youraliyunkeysecrets \
    --ep oss-cn-hangzhou.aliyuncs.com  \
    --bucket etcdbackup  \
    --objectPath /sealos/ 
1
2
3
4
5
6
7
8

升级k8s版本
参考: https://www.sealyun.com/instructions/5

!升级前注意事项:

# 确保集群是健康状态
kubectl get nodes -owid

# 确保kube-system下的pod运行正常
kubectl get pod -n kube-system -owide
1
2
3
4
5

执行升级
版本必须要大于等于1.18.0，才可升级
执行升级前提前下载好新版本的离线安装包

# 升级到1.19.2版本
sealos upgrade --version v1.19.2 --pkg-url /root/kube1.19.2.tar.gz -f | tee -a upgrade.1183-1192.log 
1
2

containerd常用
https://blog.csdn.net/omaidb/article/details/128673207
