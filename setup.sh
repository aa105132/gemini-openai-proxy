#!/bin/bash

# --- 变量定义 ---
TARGET_DIR="$HOME/gemini-proxy-repo"
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}   Gemini Proxy 全自动修复/部署/启动      ${NC}"
echo -e "${BLUE}==========================================${NC}"

# 1. 基础环境检测
echo -e "${BLUE}>> [1/5] 检查基础环境...${NC}"
if ! command -v git &> /dev/null || ! command -v node &> /dev/null; then
    echo -e "${YELLOW}正在自动安装 Git 和 Node.js...${NC}"
    pkg update -y
    pkg install git nodejs -y
else
    echo -e "${GREEN}Git 和 Node.js 已就绪。${NC}"
fi

# 2. 拉取/更新代码
echo -e "${BLUE}>> [2/5] 同步最新代码...${NC}"
if [ -d "$TARGET_DIR" ]; then
    cd "$TARGET_DIR"
    git fetch --all
    git reset --hard origin/main
    git pull
    echo -e "${GREEN}代码已更新。${NC}"
else
    git clone https://github.com/aa105132/gemini-openai-proxy.git "$TARGET_DIR"
    cd "$TARGET_DIR"
fi

# 3. !!! 核心修复：自动处理 package.json !!!
echo -e "${BLUE}>> [3/5] 智能修复依赖配置...${NC}"

# 如果 package.json 不存在，说明是裸奔代码，我们需要生成一个
if [ ! -f "package.json" ]; then
    echo -e "${YELLOW}⚠️  未检测到 package.json，正在自动生成...${NC}"
    npm init -y > /dev/null
    
    echo -e "${YELLOW}正在自动补全常用库 (express, axios, etc)...${NC}"
    # 这里强制安装常用的库，以此解决 ENOENT 问题，无论用没用到都不会报错
    npm install express axios cors node-fetch body-parser --save
else
    echo -e "${GREEN}检测到配置文件，准备安装...${NC}"
fi

# 4. 安装依赖
echo -e "${BLUE}>> [4/5] 安装/更新 NPM 依赖...${NC}"
npm install

# 检查 PM2
if ! command -v pm2 &> /dev/null; then
    echo -e "${YELLOW}正在安装 PM2...${NC}"
    npm install -g pm2
fi

# 5. 启动服务
echo -e "${BLUE}>> [5/5] 重启服务...${NC}"
# 停止旧进程
pm2 delete gemini-proxy 2>/dev/null || true

# 启动新进程
pm2 start gemini-openai-proxy.js --name "gemini-proxy" --max-memory-restart 200M
pm2 save

echo -e "${GREEN}==========================================${NC}"
echo -e " ✅ 全自动部署完成！"
echo -e " 📁 路径: $TARGET_DIR"
echo -e " 🌐 地址: http://127.0.0.1:7888"
echo -e " 📝 日志: pm2 log gemini-proxy"
echo -e "${GREEN}==========================================${NC}"

exit 0
