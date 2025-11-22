#!/bin/bash

# ... (前面的环境检查和安装依赖代码保持不变) ...

# ==========================================
# ⚠️ 核心修改：小白模式启动逻辑
# ==========================================

APP_NAME="gemini-proxy"

# 定义一个函数：当用户按 Ctrl+C 时执行
function cleanup() {
    echo -e "\n\033[1;33m检测到退出信号，正在停止服务...\033[0m"
    pm2 stop "$APP_NAME" > /dev/null 2>&1
    pm2 delete "$APP_NAME" > /dev/null 2>&1
    echo -e "\033[0;31m服务已停止。\033[0m"
    exit 0
}

# 捕获 INT 信号 (即 Ctrl + C)
trap cleanup SIGINT

echo -e "\033[0;34m>> [5/5] 正在启动服务...\033[0m"

# 1. 确保之前没有残留进程
pm2 delete "$APP_NAME" > /dev/null 2>&1

# 2. 启动 PM2 (后台模式)
# 使用 --no-daemon 可能会导致 termux 假死，所以我们用 logs 模式模拟前台
pm2 start gemini-openai-proxy.js --name "$APP_NAME" --max-memory-restart 200M --log-date-format "HH:mm:ss"

# 3. 显示成功信息
clear
echo -e "\033[1;32m==========================================\033[0m"
echo -e " ✅ 服务启动成功！(正在运行中)"
echo -e " 🌐 接口地址: http://127.0.0.1:7888"
echo -e "\033[1;32m==========================================\033[0m"
echo -e "\033[1;33m⚠️  注意：\033[0m"
echo -e "1. 保持此窗口开启以查看日志。"
echo -e "2. 按下下方的 \033[1;37mCTRL\033[0m 键然后按 \033[1;37mc\033[0m 即可停止服务。"
echo -e "\033[1;32m==========================================\033[0m"
echo -e "正在连接实时日志...\n"

# 4. 锁定在日志界面 (关键步骤)
# 这会让它看起来像一直在前台运行
pm2 log "$APP_NAME" --lines 20

# 脚本执行到这里会因为 pm2 log 而“卡住”显示日志
# 当用户按 Ctrl+C，会触发上面的 cleanup 函数，从而停止 PM2
