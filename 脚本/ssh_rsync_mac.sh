cat << 'EOF' >> ~/.zshrc

# 一键同步 SSH 免密配置 (修复数组解析版)
function ssh-fix() {
    # 1. 检查并安装 sshpass
    if ! command -v sshpass &> /dev/null; then
        echo "未发现 sshpass，正在尝试安装..."
        brew install esolitos/ipa/sshpass
    fi

    # 2. 配置你的常用密码列表
    local PASS_LIST=("8QyMLyhDfvZdLPnb@" "cid-123")

    # 3. 提取主机名并存入数组，排除通配符 *
    # 使用 () 将结果转为数组，防止被当成一个长字符串
    local HOSTS=($(grep "^Host " ~/.ssh/config | grep -vE "\*" | awk '{print $2}'))

    echo "🔍 开始扫描 ~/.ssh/config 中的主机..."

    for host in "${HOSTS[@]}"; do
        # 跳过空值
        [[ -z "$host" ]] && continue

        # 获取该 host 的用户名
        local USER_NAME=$(ssh -G "$host" | grep "^user " | awk '{print $2}')
        echo -e "\n🚀 目标: $host (用户: $USER_NAME)"

        local SUCCESS=false

        # 尝试预设密码
        for pass in "${PASS_LIST[@]}"; do
            # 增加 -o ConnectTimeout 防止卡死
            sshpass -p "$pass" ssh-copy-id -o StrictHostKeyChecking=no -o ConnectTimeout=3 -i ~/.ssh/id_ed25519.pub "$host" > /dev/null 2>&1
            
            if [ $? -eq 0 ]; then
                echo "✅ 自动配置成功！"
                SUCCESS=true
                break
            fi
        done

        # 自动尝试全部失败，转手动模式
        if [ "$SUCCESS" = false ]; then
            echo "⚠️  自动尝试失败，请手动输入密码（或 Ctrl+C 跳过当前主机）:"
            ssh-copy-id -o StrictHostKeyChecking=no -i ~/.ssh/id_ed25519.pub "$host"
            
            if [ $? -eq 0 ]; then
                echo "✅ 手动配置成功！"
            else
                echo "❌ 该主机配置跳过。"
            fi
        fi
    done
    echo -e "\n🎉 处理完毕！"
}
EOF