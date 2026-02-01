# Add content in /etc/bashrc
# Log bash user login and command history
#设置history命令时间环境变量，执行命令带执行时间
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "

#手动配置主机ipv4地址和ipv6地址
dst_ipv4=10.204.206.246
dst_ipv6=

#获取登录用户ip地址
up_client_ip=`(who am i|cut -d\( -f2|cut -d\) -f1)`

#判断登录用户ip地址类型（v4或v6）
if [ -n "`echo $up_client_ip|awk '($1 ~/[0-9]+.[0-9]+.[0-9]+.[0-9]+/)'`" ];then
    up_client_ip_v4=$up_client_ip
else
    up_client_ip_v6=${up_client_ip%\%*}
fi

#获取登录时间
up_nowtime=`(date -d now +"%Y-%m-%d %T")`

#判断当前登录用户是否为正常用户、解释器是否为-bash
if [ "`who -m|awk '{print $1}'`" = "`whoami`" ] && [ "$0" = "-bash" ] ; then
    #如果是正常用户登录，解释器为-bash 则类型为登录
    content_type="login successful"
else
    #如果是正常用户登录，解释器非-bash 则类型为su 切换普通用户类型
    content_type="su $(whoami) successful"
fi
#发送登录或su日志
logger -p user.notice -- class=\"HOST_LOGIN\" type=\"2\" time=\"$up_nowtime\" src_ipv4=\"$up_client_ip_v4\" dst_ipv4=\"$dst_ipv4\" src_ipv6=\"$up_client_ip_v6\" dst_ipv6=\"$dst_ipv6\" primary_user=\"\" secondary_user=\"`(whoami)`\" operation=\"$content_type\" content=\"login successful\" authen_status=\"Success\" log_level=\"1\" session_id=\"$$\" 2>/dev/null;

function sendLog(){
    file=$1
    file_pwd=`pwd`
    if [[ $(echo $file|grep -E "^./") ]];then
        file=${file/./`echo $file_pwd`}
    elif [[ ! $(echo $file|grep -E "^/") ]];then
        file=${file_pwd}/$file
    fi
    awk '!/^($|#| +#| +$)/' $file|awk '{print NR":"$0}'|while read cmd;do
    logger -p user.notice -- class=\"HOST_COMMAND\" type=\"3\" time=\"$cmd_date\" src_ipv4=\"$up_client_ip_v4\" dst_ipv4=\"$dst_ipv4\" src_ipv6=\"$up_client_ip_v6\" dst_ipv6=\"$dst_ipv6\" primary_user=\"\" secondary_user=\"$(whoami)\" operation=\"$file $cmd\" content=\"command\" authen_status=\"\" log_level=\"1\" session_id=\"$$\" 2>/dev/null;
    done &
}


#定义脚本获取函数
function SCRIPT_LOG(){
    #获取命令行执行历史命令
    str=$(history 1 | { read x y z o; echo $o; })
    #获取命令执行时间
    cmd_date=$(history 1 | { read x y z o; echo $y $z; })
  
    #发送历史执行
    logger -p user.notice -- class=\"HOST_COMMAND\" type=\"3\" time=\"$(date -d now +"%Y-%m-%d %T")\" src_ipv4=\"$up_client_ip_v4\" dst_ipv4=\"$dst_ipv4\" src_ipv6=\"$up_client_ip_v6\" dst_ipv6=\"$dst_ipv6\" primary_user=\"\" secondary_user=\"$(whoami)\" operation=\"$str\" content=\"command\" authen_status=\"\" log_level=\"1\" session_id=\"$$\" 2>/dev/null; 
    #获取命令行当前路径

    echo $str |sed 's#&&#;#;s#||#;#'|xargs -n1 -d\; |while read cmds;do
    file_first=$(echo $cmds|awk '{print $1}')
    first_type=`echo $file_first|grep -E "^\.$|^sh$|^bash$|^/usr/bin/sh$|^/usr/bin/bash$|^source$|^python$|^/usr/bin/python$"`

    if [[ $first_type ]];then
        for files in $(echo $cmds|awk '{$1="";print}');do
            file_out=$(echo $files|grep -E "profile$|bashrc$")
            file_type=$(file $files 2>&1 |grep -E "text|shell script")
            if [[ $file_type ]] && [[ ! $file_out ]] && [[ -r $files ]];then
                sendLog $files
                break
            fi
        done
    else
        file_type=$(file $file_first 2>&1 |grep -E "text|shell script")
        if [[  $file_type ]] && [[  -x $file_first ]] && [[ -r $file_first ]] ;then
            sendLog $file_first
        fi
    fi
    done
}


export PROMPT_COMMAND='{  SCRIPT_LOG ;}'
readonly SCRIPT_LOG
readonly up_client_ip
readonly PROMPT_COMMAND