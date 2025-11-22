#!/bin/bash

# --- 定义变量和颜色 ---
TARGET_DIR="$HOME/gemini-proxy-repo"
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- 核心函数定义 ---

# 1. 部署函数
function deploy_project() {
    echo -e "${BLUE}>> 开始部署环境...${NC}"
    
    # 安装基础软件
    pkg update -y
    pkg install git nodejs -y

    # 检查源码
    if [ -d "$TARGET_DIR" ]; then
        echo -e "${YELLOW}检测到项目已存在，正在更新代码...${NC}"
        cd "$TARGET_DIR"
        git reset --hard
        git pull
    else
        echo -e "${GREEN}正在从 GitHub 克隆仓库...${NC}"
        git clone https://github.com/aa105132/gemini-openai-proxy.git "$TARGET_DIR"
        cd "$TARGET_DIR"
    fi

    # 安装依赖
    if [ ! -d "node_modules" ]; then
        echo -e "${GREEN}正在安装 NPM 依赖 (耗时较长请耐心等待)...${NC}"
        npm install
    fi
    
    # 安装 PM2
    if ! command -v pm2 &> /dev/null; then
        echo -e "${GREEN}正在安装 PM2 进程管理器...${NC}"
        npm install -g pm2
    fi

    echo -e "${GREEN}✅ 部署完成！即将启动...${NC}"
    start_project
}

# 2. 启动函数
function start_project() {
    if [ ! -d "$TARGET_DIR" ]; then
        echo -e "${RED}❌ 错误：未检测到项目文件！${NC}"
        echo -e "${YELLOW}请先选择 [2] 一键部署${NC}"
        return
    fi

    cd "$TARGET_DIR"
    
    # 简单检查 pm2
    if ! command -v pm2 &> /dev/null; then
        echo -e "${YELLOW}检测到 PM2 未安装，尝试安装...${NC}"
        npm install -g pm2
    fi

    echo -e "${BLUE}>> 正在启动服务...${NC}"
    pm2 delete gemini-proxy 2>/dev/null || true
    pm2 start gemini-openai-proxy.js --name "gemini-proxy"
    pm2 save

    echo -e "${GREEN}==========================================${NC}"
    echo -e " 🚀 服务已成功启动！"
    echo -e " 🌐 本地地址: http://127.0.0.1:7888"
    echo -e " 📋 查看日志: pm2 log gemini-proxy"
    echo -e "${GREEN}==========================================${NC}"
}

# 3. 停止函数 (额外赠送的功能)
function stop_project() {
    pm2 stop gemini-proxy
    echo -e "${YELLOW}服务已停止${NC}"
}

# --- 主菜单逻辑 ---
clear
echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}    Gemini Proxy 管理面板 (Termux版)      ${NC}"
echo -e "${BLUE}    Repo: aa105132/gemini-openai-proxy    ${NC}"
echo -e "${BLUE}==========================================${NC}"
echo -e "请选择操作："
echo -e "${GREEN}[1] 🚀 启动 服务 (Start)${NC}"
echo -e "${YELLOW}[2] 🛠️  一键 部署/更新 (Deploy/Update)${NC}"
echo -e "${RED}[3] 🛑 停止 服务 (Stop)${NC}"
echo -e "=========================================="
read -p "请输入数字 [1-3]: " choice

case $choice in
    1)
        start_project
        ;;
    2)
        deploy_project
        ;;
    3)
        stop_project
        ;;
    *)
        echo -e "${RED}无效的选择，退出程序${NC}"
        exit 1
        ;;
esac
