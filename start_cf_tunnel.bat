@echo off
chcp 65001 >nul
title Cloudflare Tunnel - 音频代理
color 0B

echo ========================================
echo   Cloudflare Tunnel
echo   本地音频代理隧道
echo ========================================
echo.

REM 检查 cloudflared 是否存在
if not exist cloudflared.exe (
    echo [错误] 未找到 cloudflared.exe
    echo 请从 https://github.com/cloudflare/cloudflared/releases 下载
    echo 并放置在此目录下
    pause
    exit /b 1
)

REM 启动隧道
echo [信息] 启动 Cloudflare 隧道...
echo [信息] 本地端口: 8080
echo [信息] 隧道地址将显示在下方
echo [信息] 请复制此地址到启动脚本中
echo.
echo [提示] 按 Ctrl+C 停止隧道
echo.

cloudflared.exe tunnel --url http://localhost:8080

pause
