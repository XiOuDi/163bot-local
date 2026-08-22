# 网易云音乐 Telegram Bot - 本地部署版

在本地电脑上运行，使用 Upstash 数据库，音频通过本地电脑转发，支持 CF 隧道暴露到公网。

## ✨ 特性

- 🎵 搜索、播放网易云音乐
- 📦 file_id 缓存，已发送的音频秒发
- 🎵 歌单播放（支持排队、分批、5秒去重）
- 🔧 管理员功能（开关歌单、缓存管理、Cookie 管理）
- 💾 Upstash Redis 数据库（配置和缓存持久化）
- 🌐 支持 CF 隧道（可选，用于 webhook 模式和音频代理）
- 🎨 ID3 标签嵌入（标题、艺术家、专辑、封面）

## 📋 系统要求

- Windows 10/11
- Python 3.10+
- 网络连接（能访问 Telegram 和网易云）

## 🚀 快速开始

### 重要说明

**本地部署版强制使用 Webhook 模式，禁止使用长轮询！**

必须配置：
1. Upstash Redis（存储配置和缓存）
2. CF 隧道（暴露本地服务到公网）
3. 其他配置（BOT_TOKEN、ADMIN_ID、Cookie）从 Upstash 数据库读取

### 1. 安装 Python

从 [python.org](https://www.python.org/downloads/) 下载并安装 Python 3.10+。

安装时勾选 **Add Python to PATH**。

### 2. 配置 Upstash Redis

1. 访问 [upstash.com](https://upstash.com) 注册账号
2. 创建 Redis 数据库
3. 在 Details 页面获取：
   - **REST URL**：例如 `https://xxx.upstash.io`
   - **REST Token**：例如 `xxxxxxxxxxxx`

### 3. 将配置写入 Upstash

运行以下 Python 脚本，将配置写入 Upstash：

```python
import requests

UPSTASH_URL = "https://xxx.upstash.io"  # 你的 Upstash REST URL
UPSTASH_TOKEN = "xxxxxxxxxxxx"  # 你的 Upstash REST Token
headers = {"Authorization": f"Bearer {UPSTASH_TOKEN}", "Content-Type": "application/json"}

config = {
    "bot:token": "你的Bot Token",
    "bot:admin_id": "你的管理员ID",
    "bot:cookie": "你的网易云MUSIC_U",
    "bot:quality": "standard",
}

for key, value in config.items():
    resp = requests.post(UPSTASH_URL, json=["SET", key, value], headers=headers)
    print(f"{key}: {resp.json().get('result')}")
```

### 4. 配置环境变量

复制 `.env.example` 为 `.env`，填写以下配置：

```env
# 必须配置
UPSTASH_REDIS_REST_URL=https://xxx.upstash.io
UPSTASH_REDIS_REST_TOKEN=你的Upstash Token
WEBHOOK_URL=https://xxx.trycloudflare.com（CF 隧道地址）

# 可选配置（也可从 Upstash 读取）
BOT_TOKEN=
ADMIN_ID=
NETEASE_COOKIE=
MUSIC_QUALITY=standard
PORT=8080
```

### 5. 启动 CF 隧道

1. 从 [Cloudflare 官网](https://github.com/cloudflare/cloudflared/releases) 下载 `cloudflared-windows-amd64.exe`
2. 重命名为 `cloudflared.exe`，放置在此目录下
3. 双击运行 `start_cf_tunnel.bat`
4. 启动后会显示一个地址，如 `https://xxx-xxx-xxx.trycloudflare.com`
5. 将此地址填入 `.env` 的 `WEBHOOK_URL`

### 6. 安装依赖并启动 Bot

双击运行 `start.bat`，或在命令行中执行：

```bash
pip install -r requirements.txt
python bot_v6.2.py
```

启动成功后，Bot 会使用 **Webhook 模式**运行。

## 🌐 CF 隧道配置（可选）

如果需要使用 webhook 模式或音频代理，可以使用 Cloudflare Tunnel 将本地服务暴露到公网。

### 1. 下载 cloudflared

从 [Cloudflare 官网](https://github.com/cloudflare/cloudflared/releases) 下载 `cloudflared-windows-amd64.exe`，重命名为 `cloudflared.exe`，放置在此目录下。

### 2. 启动隧道

双击运行 `start_cf_tunnel.bat`，或执行：

```bash
cloudflared.exe tunnel --url http://localhost:8080
```

启动后会显示一个地址，如：
```
https://xxx-xxx-xxx.trycloudflare.com
```

### 3. 配置隧道地址

编辑 `.env` 文件，添加：

```env
# CF 隧道地址
WEBHOOK_URL=https://xxx-xxx-xxx.trycloudflare.com
LOCAL_AUDIO_PROXY=https://xxx-xxx-xxx.trycloudflare.com
```

### 4. 重启 Bot

重启 Bot，会自动切换到 webhook 模式。

## 📖 使用方法

### 用户命令

| 命令 | 说明 |
|------|------|
| `/start` | 开始使用 |
| `/help` | 帮助信息 |
| `/play 关键词` | 搜索并播放歌曲 |
| `/playlist 歌单ID/链接` | 播放歌单（仅限私聊） |
| 内联搜索 | `@XiOuDi163_bot 歌曲名` |

### 管理员命令

| 命令 | 说明 |
|------|------|
| `/admin` | 管理员面板 |
| `/toggleplaylist` | 开关歌单播放 |
| `/playliststop` | 停止用户歌单播放 |
| `/setcookie 值` | 设置 Cookie |
| `/refreshcookie` | 刷新 Cookie |
| `/setquality standard/higher` | 设置音质 |
| `/cachetop` | 缓存热歌榜 |
| `/cacheplaylist 歌单ID` | 缓存歌单 |
| `/broadcast 消息` | 广播消息 |

## 🔧 架构说明

### Webhook + CF 隧道模式（强制）

```
用户 → Telegram → CF 隧道 → 本地 Bot（webhook）
                                ↓
                          本地下载音频
                                ↓
                     发送给用户（带 ID3 标签）
```

- 本地部署版**强制使用 Webhook 模式**，禁止使用长轮询
- 通过 CF 隧道将本地服务暴露到公网
- 配置从 Upstash 数据库读取，减少本地配置
- 音频通过本地电脑下载，添加 ID3 标签后发送

### 音频发送方式

1. **file_id 缓存**：已发送的音频直接使用 file_id，秒发（Upstash 存储）
2. **本地临时文件下载**：
   - 下载音频到本地临时文件
   - 写入 ID3 标签（标题、艺术家、专辑、封面）
   - 发送给 Telegram
   - 发送成功后立即删除临时文件
   - 保存 file_id 到 Upstash
3. **歌名校验**：file_id 缓存发送后检查歌名，不正确则删除缓存重新下载

## ❓ 常见问题

### Q: Bot 没有响应？
A: 检查 `.env` 配置是否正确，查看控制台日志。

### Q: 播放歌曲失败？
A: 检查网易云 Cookie 是否过期，使用 `/refreshcookie` 刷新。

### Q: 如何获取管理员 ID？
A: 在 Telegram 中搜索 [@userinfobot](https://t.me/userinfobot)，发送任意消息。

### Q: 如何获取网易云 Cookie？
A: 
1. 浏览器登录 [网易云音乐](https://music.163.com)
2. F12 打开开发者工具
3. Application → Cookies → 找到 `MUSIC_U`
4. 复制其值

### Q: CF 隧道地址会变吗？
A: 免费版每次启动都会变化。需要固定地址可以注册 Cloudflare 账号并配置命名隧道。

### Q: 电脑关机后 Bot 还能用吗？
A: 不能。本地部署需要电脑保持开机并运行 Bot。

## 📁 文件说明

```
├── bot_v6.2.py          # 主程序
├── config.py            # 配置文件
├── database.py          # Upstash 数据库封装
├── downloader.py        # 优化下载模块
├── netease_api.py       # 网易云 API 封装
├── logger_utils.py      # 美化日志模块
├── requirements.txt     # Python 依赖
├── .env.example         # 环境变量示例
├── start.bat            # 启动 Bot（Windows）
├── start_cf_tunnel.bat  # 启动 CF 隧道（Windows）
├── start_all.bat        # 一键启动（隧道 + Bot）
└── README.md            # 说明文档
```

> **注意**：`cloudflared.exe`（54MB）不包含在仓库中，请从 [Cloudflare 官网](https://github.com/cloudflare/cloudflared/releases) 下载 `cloudflared-windows-amd64.exe`，重命名为 `cloudflared.exe` 放置在此目录。
>
> 一键启动脚本（`启动网易云Bot.bat` / `启动网易云Bot.ps1`）和桌面快捷方式需在本地配置后生成。

## 🔗 相关链接

- 原仓库：https://github.com/XiOuDi/163music
- Render 专用版：https://github.com/XiOuDi/163bot-render
- Upstash：https://upstash.com
- Cloudflare Tunnel：https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/

## 📄 许可证

MIT License
