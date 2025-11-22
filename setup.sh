#!/bin/bash

# 定义颜色
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}   Gemini Proxy Termux 一键部署脚本   ${NC}"
echo -e "${BLUE}   Repo: aa105132/gemini-openai-proxy     ${NC}"
echo -e "${BLUE}==========================================${NC}"

# 1. 环境准备
echo -e "${GREEN}[1/5] 正在配置基础环境 (Git & Node.js)...${NC}"
pkg update -y
# 安装 git, nodejs, 并确保安装 build-essential 也就是 python, make, g++ 等，防止 npm 编译报错
pkg install git nodejs -y 

# 2. 拉取或更新仓库
TARGET_DIR="$HOME/gemini-proxy-repo"

if [ -d "$TARGET_DIR" ]; then
    echo -e "${GREEN}[2/5] 发现旧目录，正在更新代码...${NC}"
    cd "$TARGET_DIR"
    git reset --hard # 放弃本地修改，强制同步云端
    git pull
else
    echo -e "${GREEN}[2/5] 正在从 GitHub 克隆仓库...${NC}"
    git clone https://github.com/aa105132/gemini-openai-proxy.git "$TARGET_DIR"
    cd "$TARGET_DIR"
fi

# 3. 智能检查/生成 package.json (防止你也忘了传这个文件)
if [ ! -f "package.json" ]; then
    echo -e "${GREEN}[3/5] 检测到缺少 package.json，正在自动生成...${NC}"
    echo '{
      "name": "gemini-proxy",
      "version": "1.0.0",
      "scripts": {
        "start": "node gemini-openai-proxy.js"
      },
      "dependencies": {
        "express": "^4.19.2",
        "node-fetch": "^2.7.0"
      }
    }' > package.json
fi

# 4. 安装依赖
echo -e "${GREEN}[4/5] 正在安装依赖...${NC}"
npm install

# 5. 使用 PM2 启动 (守护进程)
echo -e "${GREEN}[5/5] 启动服务...${NC}"
if ! command -v pm2 &> /dev/null; then
    echo "正在安装 PM2 进程管理器..."
    npm install -g pm2
fi

# 停止旧进程防止端口冲突
pm2 delete gemini-proxy 2>/dev/null || true

# 启动
pm2 start gemini-openai-proxy.js --name "gemini-proxy"
pm2 save

echo -e "${GREEN}"
echo "=========================================="
echo " ✅ 部署完成！"
echo "=========================================="
echo " 🌐 服务地址: http://127.0.0.1:7888"
echo " 📂 项目目录: $TARGET_DIR"
echo " 📝 查看日志: pm2 log gemini-proxy"
echo " 🔄 更新代码: 只需要重新运行这条安装指令即可"
echo "=========================================="
echo -e "${NC}"
