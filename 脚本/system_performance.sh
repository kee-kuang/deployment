#!/bin/bash
#项目名称
PROJECT_NAME="中捷生产环境"

# 钉钉机器人 webhook URL
webhook_url="https://oapi.dingtalk.com/robot/send?access_token=1fd1ff15079a81a28d28fe48694c5d0f81df97df013e6ba1834d647d7aa861db"

#获取当前ip
ip=$(hostname -I | awk '{print $1}') 
# 获取当前时间
current_time=$(date "+%Y-%m-%d %H:%M:%S")

# 获取系统负载信息
loadavg=$(uptime | awk '{print $10}')

# 获取 CPU 使用率信息
cpu_usage=$(top -b -n 1 | grep "Cpu(s)" | awk '{print $2}')

# 获取内存使用情况
mem_total=$(free -m | grep "Mem:" | awk '{print $2}')
mem_used=$(free -m | grep "Mem:" | awk '{print $3}')
mem_usage=$(awk "BEGIN {printf \"%.2f\",${mem_used}/${mem_total}*100}")

# 获取磁盘使用情况
disk_usage=$(df -h | awk '$NF=="/"{printf "%s", $5}')

# 获取系统日志和应用日志是否有ERROR或EXCEPTION级别日志
log_info=$(grep -E "ERROR|EXCEPTION" /var/log/messages)


# 发送钉钉告警
timestamp=$(date +"%Y-%m-%d %H:%M:%S")
message=$(if [ -n "$log_info" ]; then
  echo "[${PROJECT_NAME}][$current_time] \n $ip \n\nSystem Load Average:\n$loadavg \n\nCPU Usage:\n$cpu_usage\n\n Memory Usage: \n$mem_usage \n\nDisk Usage: \n$disk_usage \n\nlogs errors: \n$log_info" 
else
  echo "[${PROJECT_NAME}][$current_time] \n $ip \n\nSystem Load Average:\n$loadavg\n\nCPU Usage:\n$cpu_usage\n\nMemory Usage:\n$mem_usage\n\nDisk Usage:\n$disk_usage \n\nNo log error found" 
fi)
curl -H "Content-Type: application/json" -d "{\"msgtype\": \"text\", \"text\": {\"content\": \"$message\"}}" $webhook_url
