# ansible 初始化
# 1. ansbile 传ssh root密钥到目标主机
# 2. ansbile 添加  Inventory 主机清单 到相对应的组

#定义单台主机信息
host_ip="10.0.1.200"
user=root
password=Shushangyun520!root

#ssh 生成密钥对
#ssh-keygen -t rsa

#ssh-copy-id 密钥设置
ssh-copy-id $user@$host_ip 
expect "yes"
expect "Shushangyun520!root"




