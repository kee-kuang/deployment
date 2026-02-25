import requests
import json
import time
import hmac
import hashlib
import base64
import urllib.parse

dingding_webhook_url = 'https://oapi.dingtalk.com/robot/send?access_token=d5d270c866fd51b10f3b4028520ffbec58b046e6cf50ea3daa3c543584f7ea2c'

secret = 'SEC9111c7b85d633669645c061da6fdcb6eb3bfc806075cee49b1336b7f36c7dd00'

service_names = [
    'order', 'product', 'pay', 'aftersales','purchase','product','member'
]


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
            "title": f"{service_name}-service 不可用",
            "text": f"**{service_name}-service 不可用**\n\n请立即检查相关服务的状态。"
        }
    }

    headers = {'Content-Type': 'application/json'}

    # Debugging output
    print(f"Sending alert for {service_name} to DingTalk")
    print(f"URL: {url}")
    print(f"Payload: {json.dumps(message)}")

    response = requests.post(url, data=json.dumps(message), headers=headers)
    print(response.text)
    if response.status_code == 200:
        print(f"{service_name} 告警已发送")
    else:
        print(f"发送 {service_name} 告警失败，状态码: {response.status_code}, 响应: {response.text}")


def check_service_status():
    for service_name in service_names:
        url = f"https://mallgateway.valuda.com.cn/{service_name}/health/status"

        try:
            response = requests.get(url, timeout=5)
            if response.status_code == 200:
                response_data = response.json()
                if response_data == 0:
                    print(f"{service_name} 正常")
                else:
                    print(f"{service_name} 不可用，准备告警")
                    send_dingtalk_alert(service_name)
            else:
                print(f"{service_name} 不可用，准备告警")
                send_dingtalk_alert(service_name)
        except requests.exceptions.RequestException as e:
            print(f"{service_name} 不可用: {e}")
            send_dingtalk_alert(service_name)


if __name__ == "__main__":
    check_service_status()
