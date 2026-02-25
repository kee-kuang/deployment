#!/bin/bash
LOGFILE=/var/log/rsync_nas_full.log
SRC=/nas/
DST=root@139.199.162.107:/nas/
SSH_OPTS='-T -c aes128-gcm@openssh.com -o Compression=no -o ServerAliveInterval=60'

while true; do
    echo "$(date '+%F %T') - Starting rsync..." >> $LOGFILE
    rsync -avH --numeric-ids --progress --partial -e "ssh $SSH_OPTS" $SRC $DST >> $LOGFILE 2>&1
    RET=$?
    if [ $RET -eq 0 ]; then
        echo "$(date '+%F %T') - rsync finished successfully!" >> $LOGFILE
        break
    else
        echo "$(date '+%F %T') - rsync failed with code $RET, retrying in 60s..." >> $LOGFILE
        sleep 60
    fi
done
