#此脚本主要是用于同库多sql执行
#!/bin/bash
time=$(date '+%Y-%m-%d')
export PGPASSWORD=zhongdian
echo $time "Starting  ..."
# 需要执行的表
sql=( 
    eng_process_engine
    eng_process_rule_config
    ord_base_order_pay_channel
    man_country_area
    man_currency
    man_language
    man_sensitive_word
    man_platform_parameter
    man_area
    mem_member
    mem_user
    mem_base_member_cycle_process
    mem_member_process
    mem_base_member_rule
    mem_menu
    mem_button
    mem_member_role
    mem_member_auth_type_config
    pro_template
    pro_shop
    pro_shop_rule_detail
)

ip= 172.16.240.160
user= root
database= zhongdian-uat-db
dir= /data/sql/
su postgres
for sql in "${sql[@]}";
do
 if [ $? -eq 0 ];then
 psql -h $ip -U $user -d $database -f $dir/$sql.sql
  fi 
done 
