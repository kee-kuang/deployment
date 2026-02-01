#!/usr/bin/env python3
import psutil
import subprocess
import os
import time
from datetime import datetime
import json
import urllib.request

# --- 配置区 ---
THRESHOLD_GB = 20  
CHECK_INTERVAL = 60  
CK_USER = "default"
CK_PASSWORD = "pWZIGBCV(SaZV2Zdi"
CK_HOST = "127.0.0.1"
CK_PORT = "9300"
DINGTALK_WEBHOOK = "https://oapi.dingtalk.com/robot/send?access_token=6a6efa08e390a70a952af2c9d2f37ec4f1a87eab5fe61826f6786ecf93aa3d32"

def log(message):
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{now}] {message}")

def send_dingtalk_alert(message):
    if not DINGTALK_WEBHOOK:
        return
    data = {
        "msgtype": "text",
        "text": {"content": f"[ClickHouse运维] {message}"}
    }
    try:
        req = urllib.request.Request(DINGTALK_WEBHOOK, data=json.dumps(data).encode("utf-8"), headers={"Content-Type": "application/json"})
        with urllib.request.urlopen(req, timeout=10) as response:
            response.read()
    except Exception as e:
        log(f"通知发送失败: {e}")

def exec_ck_sql(sql):
    """封装执行逻辑，增加密码环境变量安全保障"""
    env = os.environ.copy()
    env["CLICKHOUSE_PASSWORD"] = CK_PASSWORD
    try:
        subprocess.run(
            ["clickhouse-client", "-h", CK_HOST, "--port", CK_PORT, "-u", CK_USER, "-q", sql],
            env=env, capture_output=True, text=True, check=True, timeout=120
        )
        return True, ""
    except Exception as e:
        return False, str(e)

def purge_clickhouse(current_used_gb):
    msg = f"⚠️ 物理内存报警: 当前 {current_used_gb:.2f}GB / 阈值 {THRESHOLD_GB}GB"
    log(msg)
    send_dingtalk_alert(msg)
    
    # 策略：分两步走
    # 1. 尝试 jemalloc purge (不损耗查询性能，仅归还 OS)
    success, err = exec_ck_sql("SYSTEM JEMALLOC PURGE;")
    if success:
        log("已执行 SYSTEM JEMALLOC PURGE (尝试强制释放空页)")
        time.sleep(10) # 给系统一点反应时间
        
        # 再次检查，如果还是高，再动缓存
        new_mem = psutil.virtual_memory().used / (1024**3)
        if new_mem < THRESHOLD_GB:
            success_msg = f"JEMALLOC 软清理有效，内存已回落至 {new_mem:.2f}GB，无需强制清理缓存。"
            log(success_msg)
            send_dingtalk_alert(success_msg)
            return

    # 2. 如果第一步无效，再清理缓存 (会影响查询冷启动性能)
    log("JEMALLOC 清理效果不足，开始强制清理缓存...")
    cmds = ["SYSTEM DROP MARK CACHE;", "SYSTEM DROP uncompressed CACHE;"]
    for sql in cmds:
        success, err = exec_ck_sql(sql)
        if not success:
            send_dingtalk_alert(f"清理失败: {sql}\n错误: {err}")
        else:
            log(f"成功执行: {sql}")
    
    send_dingtalk_alert(f"内存清理任务已完成。清理前: {current_used_gb:.2f}GB")

def monitor():
    log(f"🚀 ClickHouse 内存监控已启动 (阈值: {THRESHOLD_GB}GB)")
    threshold_bytes = THRESHOLD_GB * 1024 * 1024 * 1024
    
    while True:
        try:
            mem = psutil.virtual_memory()
            if mem.used > threshold_bytes:
                purge_clickhouse(mem.used / (1024**3))
                time.sleep(600) # 清理后进入 10 分钟静默期，防止频繁刷磁盘
            else:
                time.sleep(CHECK_INTERVAL)
        except Exception as e:
            log(f"监控回路异常: {e}")
            time.sleep(10)

if __name__ == "__main__":
    monitor()