@echo off
chcp 65001 >nul
title 网易云音乐 Bot - 本地部署版
color 0A

echo ========================================
echo   网易云音乐 Telegram Bot
echo   本地部署版
echo ========================================
echo.

REM 检查 Python
python --version >nul 2>&1
if errorlevel 1 (
    echo [错误] 未找到 Python，请先安装 Python 3.10+
    pause
    exit /b 1
)

REM 检查依赖
echo [1/3] 检查依赖...
pip install -r requirements.txt -q
if errorlevel 1 (
    echo [错误] 依赖安装失败
    pause
    exit /b 1
)

REM 检查 .env 文件
if not exist .env (
    echo [错误] 未找到 .env 文件，请复制 .env.example 为 .env 并填写配置
    pause
    exit /b 1
)

REM 启动 Bot
echo [2/3] 启动 Bot...
echo [3/3] Bot 运行中，按 Ctrl+C 停止
echo.

python bot_v6.2.py

pause
