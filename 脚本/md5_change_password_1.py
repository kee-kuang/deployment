import paramiko
import hashlib
import random
import string

def generate_random_md5_password():
    characters = string.ascii_letters + string.digits
    random_string = ''.join(random.choice(characters) for _ in range(8))
    md5_hash = hashlib.md5(random_string.encode()).hexdigest()
    return md5_hash

def change_password(server, username, old_password, new_password):
    try:
        ssh_client = paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh_client.connect(server, username=username, password=old_password)

        # 修改密码
        stdout ,stdin , stderr = ssh_client.exec_command('passwd')
        # stdin.write(f"{old_password}\n")
        stdin.write(f"{new_password}\n")
        stdin.write(f"{new_password}\n")
        stdin.flush()

        # stdin, stdout, stderr = ssh_client.exec_command(f'echo -e "{new_password}\n{new_password}" | passwd')
        # output = stdout.read()  
        # print(output)

        print(f"密码已成功修改: {server}")
    except Exception as e:
        print(f"密码修改失败: {server}, 错误信息: {str(e)}")
    finally:
        ssh_client.close()

# 服务器列表
servers = [
    {'server': '10.0.0.26', 'username': 'root', 'old_password': '123456', 'new_password': generate_random_md5_password()},
    # {'server': '10.121.151.249', 'username': 'yaoac', 'old_password': 'HkwwewnNQLCQ8i23', 'new_password': generate_random_md5_password()},


]

# Save passwords to a file
with open("passwords.txt", "w") as file:
    for server_info in servers:
        new_password = server_info['new_password']
        file.write(f"{server_info['server']} - {server_info['username']} - {new_password}\n")

for server_info in servers:
    change_password(server_info['server'], server_info['username'], server_info['old_password'], server_info['new_password'])
