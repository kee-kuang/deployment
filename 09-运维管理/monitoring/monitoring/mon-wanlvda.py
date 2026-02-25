import requests
import json
import time
import hmac
import hashlib
import base64
import urllib.parse

# 钉钉 webhook URL
dingding_webhook_url = 'https://oapi.dingtalk.com/robot/send?access_token=18e1c536f28f09f55b67c6da02efa6eae3c44d8ab1d5462da4347624323300d8'

# 钉钉机器人加签的密钥
secret = 'SEC2be0f62e59b908a7c5b6aca0fc678c9a6c41986608c779fc8c62224e5d6efe71'

# 要检测的服务列表
services = {
    "product-service": "https://mallgateway.valuda.com.cn/product/status",
    "order-service": "https://mallgateway.valuda.com.cn/order/status"
}


def generate_sign(secret):
    timestamp = str(round(time.time() * 1000))
    secret_enc = secret.encode('utf-8')
    string_to_sign = f'{timestamp}\n{secret}'
    string_to_sign_enc = string_to_sign.encode('utf-8')
    hmac_code = hmac.new(secret_enc, string_to_sign_enc, digestmod=hashlib.sha256).digest()
    sign = urllib.parse.quote_plus(base64.b64encode(hmac_code))
    return timestamp, sign


def send_dingtalk_alert(service_name):
    timestamp, sign = generate_sign(secret)
    url = f"{dingding_webhook_url}&timestamp={timestamp}&sign={sign}"

    message = {
        "msgtype": "markdown",
        "markdown": {
            "title": f"{service_name} 不可用",
            "text": f"**{service_name} 不可用**\n\n请立即检查相关服务的状态。"
        }
    }

    headers = {'Content-Type': 'application/json'}
    response = requests.post(url, data=json.dumps(message), headers=headers)

    if response.status_code == 200:
        print(f"{service_name} 告警已发送")
    else:
        print(f"发送 {service_name} 告警失败")


def check_service_status():
    for service_name, url in services.items():
        try:
            response = requests.get(url, timeout=5)
            if response.status_code == 200 and response.text == '0':
                print(f"{service_name} 正常")
            else:
                print(f"{service_name} 不可用，准备告警")
                send_dingtalk_alert(service_name)
        except requests.exceptions.RequestException as e:
            print(f"{service_name} 不可用: {e}")
            send_dingtalk_alert(service_name)


if __name__ == "__main__":
    check_service_status()
