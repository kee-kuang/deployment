#!/bin/bash

cd /data/.jenkins

tar -czf /data/jenkins-bak/backup-$(date +%Y%m%d%H%M%S).tar.gz /data/.jenkins/* --exclude=workspace

OSS_PATH=oss://ssy-ops/backup/jenkins/

/data/ossutil64 cp -f /data/jenkins-bak/backup-*.tar.gz $OSS_PATH

FILES=($(/data/ossutil64 ls$OSS_PATH | awk '{print $4}'))
COUNT=${#FILES[@]}

if [ $COUNT -gt 6 ]; then
  OLDEST_FILE=$(printf "%s\n" "${FILES[@]}" | sort | head -n 1)
  /data/ossutil64 rm $OLDEST_FILE
fi

