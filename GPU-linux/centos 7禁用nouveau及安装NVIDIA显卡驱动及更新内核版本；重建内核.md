# centos 7禁用nouveau及安装NVIDIA显卡驱动及更新内核版本；重建内核

网上现在有数不清的教程，我这次安装过程中也参考了很多人的教程，但是错误不断，问题不断，

### 参考的链接及出现的问题

https://[linux](https://link.csdn.net/?target=https%3A%2F%2Fdevpress.csdn.net%2Fcommunity%2Fauth%3Fhcloud-service%3Dhttps%3A%2F%2Fdeveloper.huaweicloud.com%2Fspace%2Fdevportal%2Fdesktop%3Futm_source%3Dcsdndspace%26utm_adplace%3Dcsdnhyqyhz%26login%3Dfrom_csdn)config.org/how-to-install-the-nvidia-drivers-on-centos-7-linux
https://www.dedoimedo.com/computers/centos-7-nvidia.html

这两个教程大同小异，但是最后重启后我的电脑只有一个横杆在那闪，根本进不去文本模式，包括使用`Ctrl+Alt+F1-7`导致我重新安装了系统，第二次操作的时候还是同样的问题，最终找到了不用重新安装的方法。一直没有搞懂dracut命令到底是有什么用？

### 这几个教程还值得参考的，常规的安装教程

https://www.linuxidc.com/[Linux](https://link.csdn.net/?target=https%3A%2F%2Fdevpress.csdn.net%2Fcommunity%2Fauth%3Fhcloud-service%3Dhttps%3A%2F%2Fdeveloper.huaweicloud.com%2Fspace%2Fdevportal%2Fdesktop%3Futm_source%3Dcsdndspace%26utm_adplace%3Dcsdnhyqyhz%26login%3Dfrom_csdn)/2017-12/149577.htm
[–kernel-source-path=/usr/src/kernels/x.xx.x-xxxxx](https://link.csdn.net/?target=https%3A%2F%2Fwww.cnblogs.com%2Fniyeshiyoumo%2Fp%2F6845628.html%3Flogin%3Dfrom_csdn)
https://blog.csdn.net/fengtian12345/article/details/80574529
https://blog.csdn.net/kxzhaohuan/article/details/81713954

### 出现的问题

屏幕上只有一个光标在闪，但是可以通过远程SSH的方式访问。
每次启动都是无法直接进入系统，必须要按一下 ctrl + d 进入系统。

我再stackexchange上也提问了，没有得到解决
[问题链接](https://link.csdn.net/?target=https%3A%2F%2Funix.stackexchange.com%2Fquestions%2F480578%2Fcentos7-cant-login-through-the-x-but-work-for-ssh%3Flogin%3Dfrom_csdn)

### 解决方法 ## 重建内核(centos7)

[这个教程写的很详细](https://link.csdn.net/?target=https%3A%2F%2Fblog.csdn.net%2Fkikajack%2Farticle%2Fdetails%2F79396793%3Flogin%3Dfrom_csdn)
sudo yum group install “Development Tools”
sudo yum update
sudo yum install kernel-devel epel-release
这个都是要安装一下的，安装完成后重启

```autohotkey
sudo vi /etc/default/grub
添加`rd.driver.blacklist=nouveau` 在linux 开头那一句
```

添加这句的原因我觉得是我用的是磁盘阵列，所以前面有`rd`

```vim
sudo vi /lib/modprobe.d/dist-blacklist.conf
```

这里面还要在 `blacklist nvidiafb` 前面加`#`
在最后加

```apache
  blacklist nouveau
  options nouveau modeset=0 
```

下一步就是

```bash
1.备份镜像
sudo mv /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r).img.bak
2.重建镜像
sudo dracut -v /boot/initramfs-$(uname -r).img $(uname -r)
```

最后

```ebnf
reboot 
```

到了安装显卡驱动的时候了

```apache
chmod +x NVIDIA-Linux-x86_64-410.73.run
sudo ./NVIDIA-Linux-x86_64-410.73.run
```

然后一路选择`yes`

最后在终端输入`nvidia-smi`
如果如下图的显示，那就证明是安装好了！good luck
![图例](https://i-blog.csdnimg.cn/blog_migrate/455e329b25ab7cfd7a4b6d4fb9bf0b79.png)
然后还需要安装cuda，cudnn

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

