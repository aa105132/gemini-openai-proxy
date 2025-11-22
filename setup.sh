#!/bin/bash

# 定义颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TARGET_DIR="$HOME/gemini-proxy-repo"

echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}      Gemini Proxy 智能启动/部署脚本      ${NC}"
echo -e "${BLUE}==========================================${NC}"

# --- 阶段 1: 环境检查 (只在缺少环境时运行) ---
if ! command -v git &> /dev/null || ! command -v node &> /dev/null; then
    echo -e "${YELLOW}[系统] 检测到环境缺失，正在安装 Git 和 Node.js...${NC}"
    pkg update -y
    pkg install git nodejs -y
else
    echo -e "${GREEN}[系统] 环境完整，跳过基础安装。${NC}"
fi

# --- 阶段 2: 代码仓库处理 ---
if [ -d "$TARGET_DIR" ]; then
    # 目录存在 = 用户已经安装过 = 执行更新并启动
    echo -e "${YELLOW}[代码] 正在检查更行...${NC}"
    cd "$TARGET_DIR"
    git pull # 拉取最新代码，如果有更新的话
else
    # 目录不存在 = 第一次安装
    echo -e "${YELLOW}[代码] 首次部署，正在克隆仓库...${NC}"
    git clone https://github.com/aa105132/gemini-openai-proxy.git "$TARGET_DIR"
    cd "$TARGET_DIR"
fi

# --- 阶段 3: 依赖检查 ---
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}[依赖] 首次运行，正在安装 NPM 依赖...${NC}"
    npm install
fi

# --- 阶段 4: 启动服务 (PM2) ---
# 检测是否安装了 pm2，没安装就装一个
if ! command -v pm2 &> /dev/null; then
    echo -e "${YELLOW}[进程] 安装 PM2 进程守护工具...${NC}"
    npm install -g pm2
fi

echo -e "${GREEN}[启动] 正在重启服务...${NC}"
# 删除旧进程（如果有），不管有没有报错都继续
pm2 delete gemini-proxy 2>/dev/null || true
# 启动新进程
pm2 start gemini-openai-proxy.js --name "gemini-proxy"
# 保存当前进程列表，防止 Termux 后台被杀重启后丢失（可选）
pm2 save

echo -e "${BLUE}==========================================${NC}"
echo -e " ✅ 服务已启动！"
echo -e " ➡️  地址: http://127.0.0.1:7888"
echo -e " 💡 提示: 以后每次输入该命令，都会自动更新并重启"
echo -e "${BLUE}==========================================${NC}"
