#!/bin/bash

# --- 变量定义 ---
TARGET_DIR="$HOME/gemini-proxy-repo"
# 颜色代码
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}      Gemini Proxy 自动化部署/启动        ${NC}"
echo -e "${BLUE}==========================================${NC}"

# 1. 基础环境检测与安装
echo -e "${BLUE}>> [1/4] 检查基础环境 (Git/Node/PM2)...${NC}"
# 如果 git 或 node 不存在，或者是第一次运行，稍微更新一下源以防万一
if ! command -v git &> /dev/null || ! command -v node &> /dev/null; then
    echo -e "${YELLOW}正在安装 Git 和 Node.js...${NC}"
    pkg update -y
    pkg install git nodejs -y
else
    echo -e "${GREEN}基础环境已就绪。${NC}"
fi

# 2. 核心逻辑：判断是安装还是更新
echo -e "${BLUE}>> [2/4] 检查项目状态...${NC}"

if [ -d "$TARGET_DIR" ]; then
    # --- 目录存在：执行更新逻辑 ---
    echo -e "${YELLOW}检测到项目已安装，正在检查更新...${NC}"
    cd "$TARGET_DIR"
    
    # 强制重置并拉取最新代码，防止冲突
    git fetch --all
    git reset --hard origin/main
    git pull
    
    echo -e "${GREEN}代码已更新到最新版。${NC}"
else
    # --- 目录不存在：执行安装逻辑 ---
    echo -e "${GREEN}检测到首次使用，开始克隆仓库...${NC}"
    git clone https://github.com/aa105132/gemini-openai-proxy.git "$TARGET_DIR"
    cd "$TARGET_DIR"
fi

# 3. 依赖安装/更新
echo -e "${BLUE}>> [3/4] 检查/安装 NPM 依赖...${NC}"
# 无论安装还是更新，都跑一遍 install 确保没漏包（npm 自动会有缓存，很快）
npm install

# 确保 PM2 存在
if ! command -v pm2 &> /dev/null; then
    echo -e "${YELLOW}正在全局安装 PM2 管理器...${NC}"
    npm install -g pm2
fi

# 4. 启动服务
echo -e "${BLUE}>> [4/4] 正在启动/重启服务...${NC}"

# 杀掉旧进程（如果有），确保不重复启动
pm2 delete gemini-proxy 2>/dev/null || true

# 启动新进程
pm2 start gemini-openai-proxy.js --name "gemini-proxy"
pm2 save

echo -e "${GREEN}==========================================${NC}"
echo -e " ✅ 服务启动成功！(已自动更新)"
echo -e " 📁 项目路径: $TARGET_DIR"
echo -e " 🌐 服务地址: http://127.0.0.1:7888"
echo -e " 📝 查看日志: pm2 log gemini-proxy"
echo -e "${GREEN}==========================================${NC}"

# 退出脚本，不给机会报错
exit 0
