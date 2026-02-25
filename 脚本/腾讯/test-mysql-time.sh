import time
import pymysql

# 配置
HOST = "lb-dqlicx1c-r6eu8i39t4yowbk2.clb.gz-tencentclb.com"
USER = "root"
PASS = "jikp6OYL9iKBQ5Xb@"
INTERVAL = 5  # 每 10 秒测试一次

def test_handshake():
    start = time.time()
    try:
        conn = pymysql.connect(
            host=HOST,
            user=USER,
            password=PASS,
            connect_timeout=5
        )
        cursor = conn.cursor()
        cursor.execute("SELECT 1;")
        cursor.fetchall()
        cursor.close()
        conn.close()
    except Exception as e:
        elapsed_ms = None
        print(f"连接失败: {e}")
    else:
        end = time.time()
        elapsed_ms = int((end - start) * 1000)
        print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] 握手耗时: {elapsed_ms} ms")
    return elapsed_ms

if __name__ == "__main__":
    times = []
    try:
        while True:
            elapsed = test_handshake()
            if elapsed is not None:
                times.append(elapsed)
            time.sleep(INTERVAL)
    except KeyboardInterrupt:
        if times:
            min_time = min(times)
            max_time = max(times)
            avg_time = sum(times) // len(times)
            print("==============================")
            print(f"最小耗时: {min_time} ms")
            print(f"最大耗时: {max_time} ms")
            print(f"平均耗时: {avg_time} ms")
            print("==============================")
        print("脚本已停止。")
