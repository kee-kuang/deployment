### 安装cuda 12.4.

```
官方地址：https://developer.nvidia.com/cuda-12-4-0-download-archive?target_os=Linux&target_arch=x86_64&Distribution=CentOS&target_version=7&target_type=rpm_local
```

```
wget https://developer.download.nvidia.com/compute/cuda/12.4.0/local_installers/cuda-repo-rhel7-12-4-local-12.4.0_550.54.14-1.x86_64.rpm
极乐鸟地址：
wget https://jln-yuetougz.oss-cn-guangzhou.aliyuncs.com/package/cuda-repo-rhel7-12-4-local-12.4.0_550.54.14-1.x86_64.rpm

sudo rpm -i cuda-repo-rhel7-12-4-local-12.4.0_550.54.14-1.x86_64.rpm
sudo yum clean all
sudo yum -y install cuda-toolkit-12-4
```

