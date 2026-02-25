from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from webdriver_manager.chrome import ChromeDriverManager
import time

chrome_options = webdriver.ChromeOptions()

# 关键：使用你自己的 Chrome Profile
chrome_options.add_argument(
    "--user-data-dir=/Users/你的用户名/Library/Application Support/Google/Chrome"
)
chrome_options.add_argument("--profile-directory=Default")  # 或 Profile 1

# 不要 headless（第一次建议可视化）
driver = webdriver.Chrome(
    service=Service(ChromeDriverManager().install()),
    options=chrome_options
)

# 直接访问订阅页面
driver.get("https://platform.minimax.io/subscribe/audio-subscription")

# 等待页面完全渲染
time.sleep(5)

# ======== 抓取剩余量 ========
# ⚠️ selector 需要你在浏览器 F12 确认
remaining = driver.find_element(
    By.XPATH,
    "//*[contains(text(),'剩余') or contains(text(),'Remaining')]"
)

print("订阅包剩余：", remaining.text)

driver.quit()
