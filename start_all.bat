@echo off
chcp 65001 >nul
title 网易云音乐 Bot - 一键启动
color 0A

echo ========================================
echo   网易云音乐 Telegram Bot
echo   本地部署版 - 一键启动
echo ========================================
echo.

REM 检查 .env 文件
if not exist .env (
    echo [错误] 未找到 .env 文件
    echo 请复制 .env.example 为 .env 并填写配置
    pause
    exit /b 1
)

REM 检查 Python
python --version >nul 2>&1
if errorlevel 1 (
    echo [错误] 未找到 Python，请先安装 Python 3.10+
    pause
    exit /b 1
)

REM 安装依赖
echo [1/4] 安装依赖...
pip install -r requirements.txt -q

REM 检查 cloudflared
if exist cloudflared.exe (
    echo [2/4] 启动 Cloudflare 隧道...
    start "CF Tunnel" cmd /c cloudflared.exe tunnel --url http://localhost:8080
    timeout /t 5 /nobreak >nul
    echo.
    echo [提示] 请等待隧道启动，然后将显示的 https://xxx.trycloudflare.com 地址
    echo       填入 .env 文件的 WEBHOOK_URL 和 LOCAL_AUDIO_PROXY
    echo.
    set /p "=隧道地址配置完成后按回车继续..."
) else (
    echo [2/4] 未找到 cloudflared.exe，跳过隧道启动
    echo       使用 polling 模式（不需要公网 URL）
)

REM 启动 Bot
echo.
echo [3/4] 启动 Bot...
echo [4/4] Bot 运行中，按 Ctrl+C 停止
echo.

python bot_v6.2.py

pause
