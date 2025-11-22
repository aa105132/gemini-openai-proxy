#!/bin/bash

# --- Shell Script SEO (Search Engine Optimization, 脚本优化) ---
# Set -e makes the script exit immediately if a command exits with a non-zero status.
# Set -u treats unset variables as an error.
# Set -o pipefail causes a pipeline to return the exit status of the last command in the pipe that returned a non-zero status.
set -euo pipefail

# --- 变量与环境定义 ---
TARGET_DIR="$HOME/gemini-proxy-repo"
REPO_URL="https://github.com/aa105132/gemini-openai-proxy.git"
ENTRY_POINT="index.js" # 关键修正：从你之前的脚本看，这里可能是启动文件名
PROCESS_NAME="gemini-proxy"

# --- 美化输出 ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# --- 脚本主流程 ---
echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}   Gemini Proxy Ultimate One-Click Installer      ${NC}"
echo -e "${BLUE}====================================================${NC}"

# 1. 安装核心系统依赖 (Termux)
echo -e "\n${BLUE}>> [1/5] Checking System Dependencies (git, nodejs)...${NC}"
# 使用久经考验的“防炸”参数，无论如何都先执行一次
pkg update -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
pkg install git nodejs -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
echo -e "${GREEN}System dependencies are up to date.${NC}"

# 2. 同步项目代码
echo -e "\n${BLUE}>> [2/5] Syncing Project Code...${NC}"
if [ -d "$TARGET_DIR/.git" ]; then
    echo -e "${YELLOW}Existing repository found. Updating...${NC}"
    cd "$TARGET_DIR"
    git fetch --all
    git reset --hard origin/main
    git pull
else
    echo -e "${YELLOW}Cloning new repository...${NC}"
    git clone "$REPO_URL" "$TARGET_DIR"
    cd "$TARGET_DIR"
fi
echo -e "${GREEN}Code is synced to the latest version.${NC}"

# 3. 安装全局依赖 (PM2)
echo -e "\n${BLUE}>> [3/5] Checking Process Manager (pm2)...${NC}"
if ! command -v pm2 &> /dev/null; then
    echo -e "${YELLOW}pm2 not found. Installing globally...${NC}"
    # 使用 < /dev/null 防止npm“吃掉”后续的脚本命令
    npm install -g pm2 < /dev/null
else
    echo -e "${GREEN}pm2 is already installed.${NC}"
fi

# 4. 安装项目内部依赖 (NPM)
echo -e "\n${BLUE}>> [4/5] Installing Project Dependencies (npm)...${NC}"
# --omit=dev 是生产环境最佳实践，只安装运行必要的包
npm install --omit=dev < /dev/null
echo -e "${GREEN}Project dependencies installed.${NC}"

# 5. 启动或重启服务 (PM2)
echo -e "\n${BLUE}>> [5/5] Starting/Restarting Service via pm2...${NC}"
# 先尝试删除旧进程，忽略可能出现的“不存在”错误
pm2 delete "$PROCESS_NAME" 2>/dev/null || true
# 启动新进程，并设置内存超出限制时自动重启
pm2 start "$ENTRY_POINT" --name "$PROCESS_NAME" --max-memory-restart 200M
# 保存进程列表，以便Termux重启后自动恢复
pm2 save
echo -e "${GREEN}Service is now running under pm2.${NC}"

# --- 最终输出 ---
echo -e "\n${GREEN}====================================================${NC}"
echo -e " ✅  All-in-one deployment completed successfully!"
echo -e " 📁  Path: $TARGET_DIR"
echo -e " 🌐  Address: http://127.0.0.1:7888"
echo -e " 📝  Check logs: pm2 log $PROCESS_NAME"
echo -e " 📈  Check status: pm2 status"
echo -e "${GREEN}====================================================${NC}"

# 为了方便用户，自动显示最近的日志
sleep 1
echo -e "\n${BLUE}Displaying recent logs (Press Ctrl+C to exit)...${NC}"
pm2 logs --lines 15 "$PROCESS_NAME"

exit 0
