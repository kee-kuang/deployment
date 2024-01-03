#此脚本主要是多库循环备份
#!/bin/bash
time=$(date '+%Y-%m-%d')
export PGPASSWORD=dbadmin
echo "Starting Backup PostgreSQL ..."
# 需要备份的库
database=( 
v3-2023-test
)

ip=10.0.0.11
user=dbadmin
for database in "${database[@]}";
do
 if [ $? -eq 0 ];then
  rm -rf /data/pgsql_backup/pgsql-backup-$database.gz   
   echo "Finsh del old backup-file"
  pg_dump  -O -U $user -p 5432 -h $ip -d $database > /data/pgsql_backup/pgsql-backup-$database.sql
  tar -Pzcvf /data/pgsql_backup/pgsql-backup-$database.gz /data/pgsql_backup/pgsql-backup-$database.sql 
# && rm -rf /data/pgsql_backup/pgsql-backup-$database.sql
/data/ossutil64 cp -r -f /data/pgsql_backup/pgsql-backup-$database.gz oss://ssy-ops/backup/postgresql/
sleep 30
  echo "Finish Backup-$database-$time"
  fi 
done 
if [ $? -eq 0 ];then
echo "Finish Backup ..."
else 
echo "bad"
fi
