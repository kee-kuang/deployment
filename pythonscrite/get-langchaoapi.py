#CREATE TABLE servers (
#    ip_address VARCHAR(15) NOT NULL,
#    os_version VARCHAR(50),
#    parameter1 VARCHAR(255),
#    parameter2 VARCHAR(255),
#    
#    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
#);

import requests
import json
import mysql.connector
import re

# 配置数据库连接 mysql
db_config = {
    'host': '',
    'user': '',
    'password': '',
    'database': ''
}

# 配置 API 地址
api_url = ''

# 发送 GET 请求获取服务器信息
response = requests.get(api_url)

# 如果请求成功，处理返回的 JSON 数据
if response.status_code == 200:
    server_data = response.json()

    # 使用正则表达式筛选主要参数
    # 你需要根据实际的 JSON 结构进行调整
    filtered_data = {
        'parameter1': re.search(r'pattern1', str(server_data)).group(1),
        'parameter2': re.search(r'pattern2', str(server_data)).group(1),
    }

    # 将筛选后的数据写入 MySQL 数据库
    try:
        connection = mysql.connector.connect(**db_config)
        cursor = connection.cursor()

        # 以下示例假设已经有一个名为 'servers' 的表，你需要根据实际情况调整表名和字段名
        insert_query = "INSERT INTO servers (parameter1, parameter2) VALUES (%s, %s)"
        cursor.execute(insert_query, (filtered_data['parameter1'], filtered_data['parameter2']))
        
        connection.commit()
        print("数据插入成功")

    except mysql.connector.Error as err:
        print(f"错误: {err}")

    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()
            print("数据库连接已关闭")

else:
    print(f"请求失败，状态码: {response.status_code}")
