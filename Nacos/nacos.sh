#!/bin/bash

# Nacos集群节点列表
nodes=("machine1" "machine2" "machine3")

# Nacos版本和下载链接
nacos_version="2.0.3"
nacos_download_url="https://github.com/alibaba/nacos/releases/download/${nacos_version}/nacos-server-${nacos_version}.tar.gz"

# 循环遍历节点列表
for node in "${nodes[@]}"; do
  echo "在 ${node} 上部署 Nacos..."

  # 在每个节点上执行安装和配置步骤
  ssh user@"${node}" 'bash -s' << EOF
    # 下载Nacos安装文件
    wget "${nacos_download_url}"

    # 解压安装文件
    tar xzf nacos-server-${nacos_version}.tar.gz

    # 进入解压后的目录
    cd nacos/bin

    # 复制配置文件
    cp cluster.conf.example cluster.conf

    # 修改Nacos配置文件
    sed -i 's#^server.address=.*#server.address=${node}#' ../conf/application.properties
    sed -i 's#^cluster.nodes=.*#cluster.nodes=${nodes[*]}#' cluster.conf
EOF

  # 在每个节点上启动Nacos服务
  ssh user@"${node}" 'bash -s' << EOF
    cd nacos/bin
    sh startup.sh -m standalone
EOF

  echo "在 ${node} 上部署完成！"
done

echo "Nacos集群部署完成！"