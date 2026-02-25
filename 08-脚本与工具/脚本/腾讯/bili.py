import requests
import pandas as pd
from datetime import date
from pathlib import Path

UID = "15377173"   # ← 确认是纯数字
OUT = Path("data/bilibili_daily.csv")

url = f"https://api.bilibili.com/x/space/upstat?mid={UID}"

HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/120.0.0.0 Safari/537.36"
    ),
    "Referer": "https://space.bilibili.com/"
}

r = requests.get(url, headers=HEADERS, timeout=10)

# ---- 强校验 ----
if r.status_code != 200:
    raise RuntimeError(f"HTTP {r.status_code}: {r.text[:200]}")

try:
    payload = r.json()
except Exception:
    raise RuntimeError(f"非 JSON 返回：{r.text[:200]}")

if payload.get("code") != 0:
    raise RuntimeError(f"B站接口异常返回：{payload}")

data = payload["data"]


archive = data.get("archive", {})

row = {
    "时间": date.today().isoformat(),
    "播放量": archive.get("view", 0),
    "评论": archive.get("reply", 0),
    "收藏": archive.get("favorite", 0),
    "硬币": archive.get("coin", 0),
    "分享": archive.get("share", 0),
    "点赞": data.get("likes", 0),
    "净增粉丝": data.get("follower", 0),
}

df = pd.DataFrame([row])
OUT.parent.mkdir(exist_ok=True)

if OUT.exists():
    df.to_csv(OUT, mode="a", header=False, index=False)
else:
    df.to_csv(OUT, index=False)

print("✅ B站抓取成功：")
print(row)
