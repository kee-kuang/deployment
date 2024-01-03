#/bin/bash
time=$(date '+%Y-%m-%d')
export PGPASSWORD= #ecs6@db!aPosgreEsql}
database=scmdb_hk
pg_dump -Ft -U postgres -p 5432 -h localhost -d $database > /data/pgsql_backup/pgsql-backup-$database.$time.tar && 
  tar -Pzcvf /data/pgsql_backup/pgsql-backup-$database.$time.tar.gz /data/pgsql_backup/pgsql-backup-$database.$time.tar  && rm -rf /data/pgsql_backup/pgsql-backup-$database.$time.tar
   /data/ossutil64 cp /data/pgsql_backup/pgsql-backup-$database.$time.tar.gz oss://ssy-ops/backup/postgresql/


