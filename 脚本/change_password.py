import paramiko

def change_password(server, username, old_password, new_password):
    try:
        ssh_client = paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh_client.connect(server, port=10086, username=username, password=old_password)

        # 修改密码
        # ssh_client.exec_command('echo "{}:{}" | chpasswd'.format(username, new_password))
        stdin, stdout, stderr = ssh_client.exec_command('passwd')
        stdin.write(f"{old_password}\n")
        stdin.write(f"{new_password}\n")
        stdin.write(f"{new_password}\n")
        stdin.flush()

        print(f"密码已成功修改: {server}")
    except Exception as e:
        print(f"密码修改失败: {server}, 错误信息: {str(e)}")
    finally:
        ssh_client.close()
# 服务器列表
servers = [
    {'server': '10.121.151.115', 'username': 'yaoac', 'old_password': 'HkwwewnNQLCQ8i23', 'new_password': '@umZXafonLAvdL4z'},
    {'server': '10.121.151.249', 'username': 'yaoac', 'old_password': 'HkwwewnNQLCQ8i23', 'new_password': '@umZXafonLAvdL4z'},
    {'server': '10.121.151.197', 'username': 'yaoac', 'old_password': 'HkwwewnNQLCQ8i23', 'new_password': '@umZXafonLAvdL4z'},
    {'server': '10.121.151.88', 'username': 'yaoac', 'old_password': 'HkwwewnNQLCQ8i23', 'new_password': '@umZXafonLAvdL4z'},
    {'server': '10.121.151.74', 'username': 'yaoac', 'old_password': 'HkwwewnNQLCQ8i23', 'new_password': '@umZXafonLAvdL4z'},
    {'server': '10.121.151.64', 'username': 'yaoac', 'old_password': 'HkwwewnNQLCQ8i23', 'new_password': '@umZXafonLAvdL4z'},
    {'server': '10.121.151.110', 'username': 'yaoac', 'old_password': 'GDtyy@2023', 'new_password': '@umZXafonLAvdL4z'},
    {'server': '10.121.151.235', 'username': 'yaoac', 'old_password': 'GDtyy@2023', 'new_password': '@umZXafonLAvdL4z'},
    {'server': '10.121.151.132', 'username': 'yaoac', 'old_password': 'HkwwewnNQLCQ8i23', 'new_password': '@umZXafonLAvdL4z'},
    {'server': '10.121.151.149', 'username': 'yaoac', 'old_password': 'HkwwewnNQLCQ8i23', 'new_password': '@umZXafonLAvdL4z'},
    # {'server': '10.121.151.46', 'username': 'yaoac', 'old_password': '@umZXafonLAvdL4z', 'new_password': '@umZXafonLAvdL4z'},
    {'server': '10.121.151.82', 'username': 'yaoac', 'old_password': 'HkwwewnNQLCQ8i23', 'new_password': '@umZXafonLAvdL4z'},
    {'server': '10.121.151.151', 'username': 'yaoac', 'old_password': 'HkwwewnNQLCQ8i23', 'new_password': '@umZXafonLAvdL4z'},
    {'server': '10.121.151.245', 'username': 'yaoac', 'old_password': 'HkwwewnNQLCQ8i23', 'new_password': '@umZXafonLAvdL4z'},
    {'server': '10.121.151.128', 'username': 'yaoac', 'old_password': 'HkwwewnNQLCQ8i23', 'new_password': '@umZXafonLAvdL4z'},
    {'server': '10.121.151.66', 'username': 'yaoac', 'old_password': 'HkwwewnNQLCQ8i23', 'new_password': '@umZXafonLAvdL4z'},
]

for server_info in servers:
    change_password(server_info['server'], server_info['username'], server_info['old_password'], server_info['new_password'])






