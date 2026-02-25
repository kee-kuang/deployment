#虽然默认 ACL 可以控制目录的权限继承，但文件默认不会继承执行位（x），因此即使设置了 default:other::rwx，文件的权限仍为 666（rw-rw-rw-），而目录的权限为 777（rwxrwxrwx）。
#因此，需要在 setfacl 之后再执行 chmod -R 777 storage，以确保目录下的文件也有执行权限。
#通过 inotify 监控并动态修改权限
#yum install inotify-tools -y
#watch_logs.sh
#!/bin/bash
LOG_DIR="/www/yuetougz.com/backend/storage/logs"
inotifywait -m -e create --format '%w%f' "$LOG_DIR" | while read FILE
do
    chmod 777 "$FILE"
done

#chmod +x watch_logs.sh
#nohup ./watch_logs.sh > /dev/null 2>&1 &
