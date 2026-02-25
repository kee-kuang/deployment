### Centos 7 k8s1.22 版本 (sealos 部署)

#### 关闭防火墙和selinux 

```
systemctl status firewalld
systemctl stop firewalld
getenforce 
setenforce 0
```

#### 安装步骤

```
wget https://ssy-ops.oss-cn-shenzhen.aliyuncs.com/software/K8S/kube1.22.0.tar.gz
wget https://ssy-ops.oss-cn-shenzhen.aliyuncs.com/software/K8S/sealos
mv sealos /usr/bin/
chmod +x /usr/bin/sealos
sealos init --passwd {服务器密码} --master {服务器ip} --node {服务器ip} --node {服务器ip} --pkg-url /root/kube1.22.0.tar.gz{k8s 包路径}  --version v1.22.0 --podcidr 10.93.0.0/12 --svccidr 10.244.0.0/16
```

