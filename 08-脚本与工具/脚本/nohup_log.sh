# !/bin/sh
# 拷贝日志文件到 昨天的log中
split -b 10k -d -a 4 /root/warehouse/nohup.out /root/warehouse/logfile_`date -d yesterday +%Y%m%d`.log  
# 清空nohup.out 日志
cat /dev/null >/root/warehouse/nohup.out
