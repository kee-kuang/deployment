#!/bin/bash


#变量定义
jdk_download="https://keekuang.oss-cn-guangzhou.aliyuncs.com/packet/jdk1.8.0_241.tar.gz"
install_jdkdir="/usr/local/jdk1.8.0_241"
bashrc_path="/etc/profile"

Nacos_host= ("10.0.1.110" "10.0.1.120" "10.0.1.130")  
Nacos_passwd=()
Nacos_download="https://keekuang.oss-cn-guangzhou.aliyuncs.com/packet/Nacos/nacos-server-2.2.2.zip"
Nacos_dir="/data/nacos"


#Jdk

#判断 jdk 是否安装成功
if [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]]; then
    echo "JDK已安装，JAVA_HOME路径为: $JAVA_HOME"
else
    echo "JDK未安装或JAVA_HOME未正确配置"
    
    wget "$jdk_download" -P /tmp

    echo "解压jdk.... "
    mkdir "$install_jdkdir"
    tar xf "/tmp/$(basename "$jdk_download")" -C "$install_jdkdir" --strip-components=1
    echo  "增加环境变量..."
    cat <<EOF >> "$bashrc_path"
export JAVA_HOME="$install_jdkdir"
export PATH="\$JAVA_HOME/bin:\$PATH"
export CLASSPATH=".:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar"
EOF
    source "$bashrc_path"

# 验证是否安装成功
    if [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]]; then
            echo "JDK安装成功，JAVA_HOME路径为: $JAVA_HOME"
        else
            echo "JDK安装失败，请检查安装过程中的错误信息"
    fi
fi

echo -----------------------------------------------------------------------------------------

# Nacos 


if [ -d "$Nacos_dir" ]; then
    echo "Nacos is already deployed."
else
    echo "Install Nacos..."
    wget $Nacos_download -P /data/nacos
    unzip /data/""
    echo 
    cd nacos/bin
    sh startup.sh 
fi
