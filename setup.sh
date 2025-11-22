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
    pkg update -y
    pkg install git nodejs -y

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

    if [ ! -d "node_modules" ]; then
        echo -e "${GREEN}正在安装 NPM 依赖...${NC}"
        npm install
    fi
    
    if ! command -v pm2 &> /dev/null; then
        echo -e "${GREEN}正在安装 PM2...${NC}"
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
    
    if ! command -v pm2 &> /dev/null; then
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

# 3. 停止函数
function stop_project() {
    pm2 stop gemini-proxy 2>/dev/null
    echo -e "${YELLOW}服务已停止${NC}"
}

# 4. 卸载函数 (新增)
function uninstall_project() {
    echo -e "${RED}⚠️  高能预警：这将停止服务并删除所有文件！${NC}"
    # 这里的 read 也要加 < /dev/tty 以防万一
    read -p "❓ 确认要卸载吗? (y/n): " confirm < /dev/tty
    
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        echo -e "${BLUE}>> 正在清理 PM2 进程...${NC}"
        pm2 delete gemini-proxy 2>/dev/null
        pm2 save
        
        echo -e "${BLUE}>> 正在删除项目文件...${NC}"
        rm -rf "$TARGET_DIR"
        
        echo -e "${GREEN}✅ 卸载完成，江湖有缘再见！${NC}"
    else
        echo -e "${GREEN}操作已取消${NC}"
    fi
}

# --- 主菜单逻辑 ---
# 强制清屏，让界面更干净
clear 

echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}    Gemini Proxy 管理面板 (Termux版)      ${NC}"
echo -e "${BLUE}    Repo: aa105132/gemini-openai-proxy    ${NC}"
echo -e "${BLUE}==========================================${NC}"
echo -e "请选择操作："
echo -e "${GREEN}[1] 🚀 启动 服务 (Start)${NC}             - 日常使用选这个"
echo -e "${YELLOW}[2] 🛠️  一键 部署/更新 (Deploy)${NC}      - 第一次或更新选这个"
echo -e "${RED}[3] 🛑 停止 服务 (Stop)${NC}"
echo -e "${RED}[4] 🗑️  卸载 服务 (Uninstall)${NC}"
echo -e "=========================================="

# !!! 关键修复：加上 < /dev/tty !!!
read -p "请输入数字 [1-4]: " choice < /dev/tty

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
    4)
        uninstall_project
        ;;
    *)
        echo -e "${RED}无效的选择，退出程序${NC}"
        exit 1
        ;;
esac
