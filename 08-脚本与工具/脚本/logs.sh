now_date=`date +'%Y%m%d'`
yesterday_date=$(date -d "$now_date -1 day" +'%Y%m%d')

cd /usr/local/webserver/nginx/logs/
mkdir  ${yesterday_date}
mv *-${yesterday_date}*  ${yesterday_date}