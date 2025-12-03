# Production Deployment Guide

使用 Gunicorn + Uvicorn Workers 部署 Tetris Dual Backend 到生產環境。

## 📋 目錄

- [快速開始](#快速開始)
- [Gunicorn 配置](#gunicorn-配置)
- [環境變數](#環境變數)
- [部署方式](#部署方式)
- [性能優化](#性能優化)
- [監控和日誌](#監控和日誌)
- [安全性](#安全性)

---

## 快速開始

### 1. 安裝依賴

```bash
cd backend
uv sync
```

這會安裝包括 Gunicorn 在內的所有依賴。

### 2. 配置環境變數

編輯 `.env` 檔案：

```env
# Database
DATABASE_URL=mysql+pymysql://root:PASSWORD@localhost/tetris-dual

# CORS
CORS_ORIGINS=https://yourdomain.com,https://www.yourdomain.com

# Server
HOST=0.0.0.0
PORT=8000

# Gunicorn (Production)
WORKERS=4
LOG_LEVEL=info
RELOAD=false
```

### 3. 啟動生產伺服器

**Linux/Mac:**
```bash
./start-prod.sh
```

**Windows:**
```bash
start-prod.bat
```

**手動啟動:**
```bash
uv run gunicorn app.main:app \
    --config gunicorn.conf.py \
    --worker-class uvicorn.workers.UvicornWorker
```

---

## Gunicorn 配置

### gunicorn.conf.py

配置檔案位於 `backend/gunicorn.conf.py`，包含以下設定：

#### Worker 設定

```python
# Worker 數量（預設為 CPU 核心數 * 2 + 1）
workers = 4

# Worker 類型（必須使用 UvicornWorker for FastAPI）
worker_class = 'uvicorn.workers.UvicornWorker'

# 每個 worker 的連接數
worker_connections = 1000

# Worker 超時（秒）
timeout = 30
```

#### 綁定設定

```python
# 綁定地址和端口
bind = "0.0.0.0:8000"

# Backlog 佇列大小
backlog = 2048
```

#### 日誌設定

```python
# 訪問日誌（stdout）
accesslog = '-'

# 錯誤日誌（stderr）
errorlog = '-'

# 日誌等級
loglevel = 'info'
```

---

## 環境變數

### 必要變數

| 變數 | 說明 | 範例 |
|------|------|------|
| `DATABASE_URL` | MySQL 連接字串 | `mysql+pymysql://user:pass@host/db` |
| `CORS_ORIGINS` | 允許的來源（逗號分隔） | `https://example.com` |

### 選用變數

| 變數 | 說明 | 預設值 |
|------|------|--------|
| `HOST` | 綁定主機 | `0.0.0.0` |
| `PORT` | 綁定端口 | `8000` |
| `WORKERS` | Worker 數量 | `CPU * 2 + 1` |
| `LOG_LEVEL` | 日誌等級 | `info` |
| `RELOAD` | 自動重載（僅開發） | `false` |

---

## 部署方式

### 方式 1: Systemd Service (Linux)

創建 `/etc/systemd/system/tetris-backend.service`：

```ini
[Unit]
Description=Tetris Dual Backend
After=network.target mysql.service

[Service]
Type=notify
User=www-data
Group=www-data
WorkingDirectory=/var/www/tetris-dual/backend
Environment="PATH=/var/www/tetris-dual/backend/.venv/bin"
ExecStart=/usr/local/bin/uv run gunicorn app.main:app --config gunicorn.conf.py --worker-class uvicorn.workers.UvicornWorker
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

啟用和啟動服務：

```bash
sudo systemctl daemon-reload
sudo systemctl enable tetris-backend
sudo systemctl start tetris-backend
sudo systemctl status tetris-backend
```

### 方式 2: Docker

創建 `Dockerfile`：

```dockerfile
FROM python:3.12-slim

# Install uv
RUN pip install uv

# Set working directory
WORKDIR /app

# Copy project files
COPY pyproject.toml .
COPY app/ app/
COPY gunicorn.conf.py .
COPY .env .

# Install dependencies
RUN uv sync

# Expose port
EXPOSE 8000

# Start with Gunicorn
CMD ["uv", "run", "gunicorn", "app.main:app", "--config", "gunicorn.conf.py", "--worker-class", "uvicorn.workers.UvicornWorker"]
```

構建和運行：

```bash
docker build -t tetris-backend .
docker run -p 8000:8000 tetris-backend
```

### 方式 3: Nginx 反向代理

Nginx 配置 `/etc/nginx/sites-available/tetris`:

```nginx
upstream tetris_backend {
    server 127.0.0.1:8000 fail_timeout=0;
}

server {
    listen 80;
    server_name api.yourdomain.com;

    # Redirect to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.yourdomain.com;

    # SSL certificates
    ssl_certificate /etc/letsencrypt/live/api.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.yourdomain.com/privkey.pem;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Proxy settings
    location / {
        proxy_pass http://tetris_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Health check endpoint
    location /health {
        proxy_pass http://tetris_backend/health;
        access_log off;
    }
}
```

啟用配置：

```bash
sudo ln -s /etc/nginx/sites-available/tetris /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

## 性能優化

### Worker 數量計算

**公式：**
```
workers = (2 × CPU 核心數) + 1
```

**範例：**
- 2 核心 CPU → 5 workers
- 4 核心 CPU → 9 workers
- 8 核心 CPU → 17 workers

**調整建議：**
- I/O 密集型應用（資料庫查詢多）→ 增加 workers
- CPU 密集型應用（計算多）→ 減少 workers
- 記憶體限制 → 減少 workers

### Worker Timeout

根據應用特性調整：

```python
# 快速 API（大部分 < 1 秒）
timeout = 30

# 有長時間查詢
timeout = 60

# 有批量處理
timeout = 120
```

### 連接設定

```python
# 高併發場景
worker_connections = 2000
backlog = 4096

# 一般場景
worker_connections = 1000
backlog = 2048
```

### 資料庫連接池

在 `app/database.py` 中調整：

```python
engine = create_engine(
    DATABASE_URL,
    pool_size=20,           # 連接池大小
    max_overflow=40,        # 最大溢出連接
    pool_pre_ping=True,     # 連接前檢查
    pool_recycle=3600,      # 每小時回收連接
)
```

---

## 監控和日誌

### 日誌格式

Gunicorn 使用自定義日誌格式：

```
%(h)s - Remote address
%(t)s - Time
%(r)s - Request line
%(s)s - Status code
%(b)s - Response size
%(D)s - Request duration (microseconds)
```

### 日誌輸出到檔案

修改 `gunicorn.conf.py`：

```python
accesslog = '/var/log/tetris/access.log'
errorlog = '/var/log/tetris/error.log'
```

### 使用 Supervisor 監控

安裝 Supervisor：

```bash
sudo apt install supervisor
```

創建配置 `/etc/supervisor/conf.d/tetris-backend.conf`：

```ini
[program:tetris-backend]
command=/path/to/uv run gunicorn app.main:app --config gunicorn.conf.py --worker-class uvicorn.workers.UvicornWorker
directory=/var/www/tetris-dual/backend
user=www-data
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=/var/log/tetris/supervisor.log
```

管理服務：

```bash
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl status tetris-backend
sudo supervisorctl restart tetris-backend
```

### 健康檢查

設定定期健康檢查：

```bash
# 使用 curl
*/5 * * * * curl -f http://localhost:8000/health || echo "Health check failed"

# 使用 systemd timer
# /etc/systemd/system/tetris-healthcheck.timer
[Unit]
Description=Tetris Backend Health Check Timer

[Timer]
OnBootSec=5min
OnUnitActiveSec=5min

[Install]
WantedBy=timers.target
```

---

## 安全性

### 1. 環境變數保護

```bash
# 設定檔案權限
chmod 600 .env
chown www-data:www-data .env
```

### 2. 資料庫安全

```env
# 使用強密碼
DATABASE_URL=mysql+pymysql://tetris_user:STRONG_PASSWORD@localhost/tetris-dual

# 限制資料庫使用者權限
GRANT SELECT, INSERT, UPDATE ON tetris-dual.* TO 'tetris_user'@'localhost';
```

### 3. CORS 設定

```env
# 只允許特定域名
CORS_ORIGINS=https://tetris.yourdomain.com
```

### 4. Rate Limiting

安裝 slowapi：

```bash
uv add slowapi
```

在 `app/main.py` 中：

```python
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

@app.post("/api/games")
@limiter.limit("10/minute")
async def create_game(request: Request, ...):
    ...
```

### 5. HTTPS

使用 Let's Encrypt：

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d api.yourdomain.com
```

### 6. 防火牆

```bash
# 只開放必要端口
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS
sudo ufw enable
```

---

## 疑難排解

### Worker 崩潰

**症狀：** Workers 頻繁重啟

**檢查：**
```bash
# 查看記憶體使用
free -h

# 查看錯誤日誌
tail -f /var/log/tetris/error.log
```

**解決：**
- 減少 worker 數量
- 增加伺服器記憶體
- 檢查記憶體洩漏

### 連接超時

**症狀：** 502 Bad Gateway

**檢查：**
```python
# 增加 timeout
timeout = 60
```

**解決：**
- 優化慢查詢
- 增加 worker timeout
- 使用快取

### 高負載

**症狀：** 回應緩慢

**檢查：**
```bash
# CPU 使用率
top

# 網路連接
netstat -an | grep 8000 | wc -l
```

**解決：**
- 增加 workers
- 使用 Redis 快取
- 啟用資料庫索引

---

## 效能基準

### 預期效能

- **吞吐量：** 1000-5000 req/s（取決於硬體）
- **回應時間：** < 100ms（P95）
- **並發連接：** 10000+

### 壓力測試

使用 wrk：

```bash
# 安裝 wrk
sudo apt install wrk

# 測試 GET 請求
wrk -t12 -c400 -d30s http://localhost:8000/api/leaderboard

# 測試 POST 請求
wrk -t12 -c400 -d30s -s post.lua http://localhost:8000/api/games
```

---

## 備份策略

### 資料庫備份

```bash
#!/bin/bash
# backup.sh

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/var/backups/tetris"
DB_NAME="tetris-dual"

# 建立備份目錄
mkdir -p $BACKUP_DIR

# 備份資料庫
mysqldump -u root $DB_NAME | gzip > $BACKUP_DIR/tetris_${TIMESTAMP}.sql.gz

# 刪除 7 天前的備份
find $BACKUP_DIR -name "tetris_*.sql.gz" -mtime +7 -delete
```

設定 cron：

```bash
# 每天凌晨 2 點備份
0 2 * * * /path/to/backup.sh
```

---

## 更新部署

### 零停機更新

```bash
#!/bin/bash
# deploy.sh

echo "🔄 Starting deployment..."

# 1. Pull latest code
git pull origin main

# 2. Install dependencies
cd backend
uv sync

# 3. Run migrations (if any)
# uv run alembic upgrade head

# 4. Reload Gunicorn gracefully
if [ -f /var/run/tetris-backend.pid ]; then
    kill -HUP $(cat /var/run/tetris-backend.pid)
    echo "✅ Gunicorn reloaded"
else
    sudo systemctl restart tetris-backend
    echo "✅ Service restarted"
fi

echo "🎉 Deployment complete!"
```

---

## 參考資源

- [Gunicorn Documentation](https://docs.gunicorn.org/)
- [Uvicorn Deployment](https://www.uvicorn.org/deployment/)
- [FastAPI Deployment](https://fastapi.tiangolo.com/deployment/)
- [Nginx Configuration](https://nginx.org/en/docs/)

