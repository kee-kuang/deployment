# -*- coding: utf-8 -*-

import requests
import json

# 自定义基本信息
corp_id = 'ww6e7726dafdf19dc4'
agent_id = '1000004'
api_secret = '8hUDje6PmlPODi1iUxMf2PQbr7_y3g-uvMcS0_g0Z7I'

# 全局变量
get_token_url = "https://qyapi.weixin.qq.com/cgi-bin/gettoken"
send_msg_url1 = "https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token="

def check_wechat_api():
    # 获取到接入token
    get_token_data = {"corpid": corp_id, "corpsecret": api_secret}
    r = requests.get(url=get_token_url, params=get_token_data, verify=False)
    my_token = r.json()['access_token']

    # 补充发送链接，填写发送内容
    send_msg_url2 = send_msg_url1 + my_token
    send_data = {
        "agentid": agent_id,
        "msgtype": "text",
        "text": {"content": "hello world"},
        "safe": "0"
    }
    # 发送Post请求，获取返回值
    r = requests.post(url=send_msg_url2, data=json.dumps(send_data), verify=False)
    return r.json()


if __name__ == '__main__':
    # 打印检测结果
    print(check_wechat_api())

