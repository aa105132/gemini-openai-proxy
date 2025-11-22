#!/bin/bash
# 遇到任何错误立即退出
set -euo pipefail

# --- 变量定义 ---
TARGET_DIR="$HOME/gemini-proxy-repo"
REPO_URL="https://github.com/aa105132/gemini-openai-proxy.git"
ENTRY_POINT="index.js"

# --- 美化输出 ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}     Gemini Proxy - 极简一键启动 (前台运行)        ${NC}"
echo -e "${BLUE}====================================================${NC}"

# 1. 安装核心系统依赖 (Git & Node.js)
echo -e "\n${BLUE}>> [1/4] 安装核心依赖...${NC}"
pkg update -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
pkg install git nodejs -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
echo -e "${GREEN}核心依赖已就绪。${NC}"

# 2. 同步项目代码
echo -e "\n${BLUE}>> [2/4] 同步项目代码...${NC}"
if [ -d "$TARGET_DIR/.git" ]; then
    echo -e "${YELLOW}发现项目目录，正在更新...${NC}"
    cd "$TARGET_DIR"
    git fetch --all
    git reset --hard origin/main
    git pull
else
    echo -e "${YELLOW}正在克隆新项目...${NC}"
    git clone "$REPO_URL" "$TARGET_DIR"
    cd "$TARGET_DIR"
fi
echo -e "${GREEN}代码已同步至最新。${NC}"

# 3. 安装项目内部依赖 (NPM)
echo -e "\n${BLUE}>> [3/4] 安装项目依赖...${NC}"
npm install --omit=dev < /dev/null
echo -e "${GREEN}项目依赖安装完成。${NC}"

# 4. 在前台启动服务
echo -e "\n${BLUE}>> [4/4] 启动服务...${NC}"
echo -e "${GREEN}====================================================${NC}"
echo -e " ✅  部署完成！程序即将开始运行..."
echo -e " 🌐  服务地址: http://127.0.0.1:7888"
echo -e " 🔴  如需停止，请直接按 ${YELLOW}Ctrl + C${NC}"
echo -e "${GREEN}====================================================${NC}"
echo -e "\n程序日志将实时显示在下方:\n"

# 直接使用 node 启动，程序会占据当前窗口
node "$ENTRY_POINT"
