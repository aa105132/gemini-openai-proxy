@echo off
:: 进入当前脚本所在的目录 (防止因为管理员权限导致路径错误)
cd /d "%~dp0"

echo ==========================================
echo           Debug Mode Setup
echo ==========================================

:: 1. 检查文件是否存在
if not exist "gemini-openai-proxy.js" (
    echo [ERROR] Can not find gemini-openai-proxy.js!
    echo Please make sure the file is in the same folder.
    echo Current Dir: %cd%
    pause
    exit /b
)

:: 2. 检查 Node.js
echo [STEP 1] Checking Node.js...
node -v >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node.js is NOT installed.
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b
)
echo Node.js is OK.

:: 3. 暴力生成 package.json (改为最简单的追加模式，防止语法错误)
if not exist "package.json" (
    echo [STEP 2] Creating package.json...
    echo { > package.json
    echo   "name": "gemini-proxy", >> package.json
    echo   "version": "1.0.0", >> package.json
    echo   "dependencies": { >> package.json
    echo     "express": "^4.19.2", >> package.json
    echo     "node-fetch": "^2.7.0" >> package.json
    echo   } >> package.json
    echo } >> package.json
    echo package.json created.
)

:: 4. 安装依赖
if not exist "node_modules" (
    echo [STEP 3] Installing dependencies...
    call npm install
    if %errorlevel% neq 0 (
        echo [ERROR] npm install failed!
        pause
        exit /b
    )
)

echo.
echo ==========================================
echo      Starting Server (Ctrl+C to stop)
echo ==========================================
echo.

:loop
node gemini-openai-proxy.js
echo.
echo [WARNING] Server crashed or closed. Restarting in 3 seconds...
timeout /t 3 >nul
goto loop

:: 最后的防线，防止窗口直接消失
pause
