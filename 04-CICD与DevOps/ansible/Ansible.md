### Ansible 

#### 安装Ansible 

``` 
yum install epel-release -y 
yum -y install ansible 

```

### 管理节点与被管理节点建立SSH信任关系 创建密钥

```
控制节点：
ssh-keygen -t rsa
将控制节点的公钥传输到被管理节点  
ssh-copy-id root@10.0.1.219
```

### 场景

```
1. 检测所有被管理主机在线状态：
ansible all -i 10.0.1.219,192.168.19.136 -m ping  
#-i : 参数后面是一个列表(List) , 因此当为一个被管理节点时 , 我们后面一定要加一个英文逗号(,) , 告知是List
2. 批量创建文件
ansible all -i 192.168.19.135,192.168.19.136 -m copy -a "src=/tmp/a.conf dest=/tmp/a.conf"
all : 在 Ansible 中 , 叫做 pattern , 即匹配 , 用来在 -i 参数的资产中匹配一部分 , all 代表匹配所有
-i : 指定Ansible的资产 , 即被管理主机 (也可以是文件名)
-m : 指定要运行的模板 , 比如这里的 ping模块 和 copy模块
-a : 指定模块的参数 , 这里ping模块没有指定参数 , copy模块指定了 src 和 dest 参数
```



### 模块

```

```

