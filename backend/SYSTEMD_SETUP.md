# Systemd Service 設定指南

## 問題診斷

### 常見問題：直接執行 OK，但 systemd service 失敗

**原因：**
- 使用 `uv` 管理套件時，需要透過 `uv run` 來啟動
- 直接調用 `.venv/bin/gunicorn` 可能缺少環境變數或依賴

**解決方案：**
使用 `uv run gunicorn` 而不是直接路徑

---

## 安裝步驟

### 1. 確認 uv 路徑

```bash
which uv
# 應該顯示: /usr/local/bin/uv 或 /home/user/.local/bin/uv
```

如果 uv 不在 PATH 中：
```bash
# 安裝 uv 到系統路徑
curl -LsSf https://astral.sh/uv/install.sh | sh
sudo ln -s ~/.local/bin/uv /usr/local/bin/uv
```

### 2. 創建日誌目錄

```bash
sudo mkdir -p /var/log/uvicorn
sudo chown ai-tracks-tetris-game:ai-tracks-tetris-game /var/log/uvicorn
```

### 3. 複製 service 檔案

```bash
sudo cp tetris-dual-backend.service /etc/systemd/system/
```

### 4. 修改 service 檔案中的路徑

編輯 `/etc/systemd/system/tetris-dual-backend.service`：

```ini
# 修改使用者
User=YOUR_USER
Group=YOUR_GROUP

# 修改工作目錄
WorkingDirectory=/path/to/your/backend

# 修改日誌路徑（如果需要）
--access-logfile /var/log/uvicorn/tetris-game-access.log \
--error-logfile /var/log/uvicorn/tetris-game-error.log
```

### 5. 重載 systemd

```bash
sudo systemctl daemon-reload
```

### 6. 啟用並啟動服務

```bash
# 啟用（開機自動啟動）
sudo systemctl enable tetris-dual-backend

# 啟動服務
sudo systemctl start tetris-dual-backend

# 查看狀態
sudo systemctl status tetris-dual-backend
```

---

## 完整 Service 檔案

```ini
[Unit]
Description=Gunicorn with Uvicorn workers to serve Tetris Dual backend (FastAPI)
After=network.target mysql.service

[Service]
User=ai-tracks-tetris-game
Group=ai-tracks-tetris-game
WorkingDirectory=/home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/backend

# 重要：確保 uv 在 PATH 中
Environment="PATH=/home/ai-tracks-tetris-game/.local/bin:/usr/local/bin:/usr/bin:/bin"

# 使用 uv run 執行（關鍵！）
ExecStart=/usr/local/bin/uv run gunicorn app.main:app \
    -w 8 \
    -k uvicorn.workers.UvicornWorker \
    -b 127.0.0.1:8098 \
    --worker-connections 1000 \
    --timeout 120 \
    --graceful-timeout 30 \
    --access-logfile /var/log/uvicorn/tetris-game-access.log \
    --error-logfile /var/log/uvicorn/tetris-game-error.log \
    --log-level info \
    --capture-output \
    --enable-stdio-inheritance

Restart=always
RestartSec=3
KillSignal=SIGTERM
KillMode=mixed
TimeoutStopSec=30
Type=notify
NotifyAccess=all

[Install]
WantedBy=multi-user.target
```

---

## 除錯步驟

### 1. 查看服務狀態

```bash
sudo systemctl status tetris-dual-backend
```

### 2. 查看完整日誌

```bash
# 查看 systemd 日誌
sudo journalctl -u tetris-dual-backend -n 100 --no-pager

# 實時查看日誌
sudo journalctl -u tetris-dual-backend -f

# 查看應用日誌
tail -f /var/log/uvicorn/tetris-game-error.log
tail -f /var/log/uvicorn/tetris-game-access.log
```

### 3. 手動測試命令

```bash
# 切換到服務使用者
sudo -u ai-tracks-tetris-game -i

# 進入工作目錄
cd /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/backend

# 測試 uv run
uv run gunicorn app.main:app \
    -w 2 \
    -k uvicorn.workers.UvicornWorker \
    -b 127.0.0.1:8098 \
    --timeout 120
```

### 4. 檢查權限

```bash
# 檢查目錄權限
ls -la /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/backend

# 檢查日誌目錄權限
ls -la /var/log/uvicorn

# 檢查使用者是否存在
id ai-tracks-tetris-game
```

### 5. 檢查依賴

```bash
cd /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/backend

# 確認依賴已安裝
uv sync

# 檢查 gunicorn 是否可用
uv run gunicorn --version
```

---

## 常見錯誤和解決方案

### 錯誤 1: `uv: command not found`

**原因：** systemd 找不到 uv 命令

**解決：**
```bash
# 找到 uv 的完整路徑
which uv

# 在 service 檔案中使用完整路徑
ExecStart=/home/ai-tracks-tetris-game/.local/bin/uv run gunicorn ...
```

### 錯誤 2: `Permission denied` (日誌檔案)

**原因：** 日誌目錄權限問題

**解決：**
```bash
sudo mkdir -p /var/log/uvicorn
sudo chown -R ai-tracks-tetris-game:ai-tracks-tetris-game /var/log/uvicorn
sudo chmod 755 /var/log/uvicorn
```

### 錯誤 3: `Failed to connect to database`

**原因：** 環境變數未載入或資料庫未啟動

**解決：**
```bash
# 確保 .env 檔案存在且可讀
ls -la /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/backend/.env

# 確保 MySQL 服務已啟動
sudo systemctl status mysql

# 在 service 中加入 MySQL 依賴
After=network.target mysql.service
```

### 錯誤 4: `ModuleNotFoundError`

**原因：** 依賴未安裝或虛擬環境問題

**解決：**
```bash
cd /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/backend

# 重新同步依賴
uv sync

# 檢查是否有 .venv
ls -la .venv
```

### 錯誤 5: `Type=notify` 相關錯誤

**原因：** Gunicorn 版本或配置問題

**解決：**
```ini
# 方案 1: 改用 simple 類型
Type=simple
# 移除 NotifyAccess=all

# 方案 2: 確保 gunicorn 支援 systemd notify
# 需要 gunicorn >= 20.0
```

---

## 服務管理命令

```bash
# 啟動
sudo systemctl start tetris-dual-backend

# 停止
sudo systemctl stop tetris-dual-backend

# 重啟
sudo systemctl restart tetris-dual-backend

# 重載配置（優雅重啟）
sudo systemctl reload tetris-dual-backend

# 查看狀態
sudo systemctl status tetris-dual-backend

# 啟用開機自動啟動
sudo systemctl enable tetris-dual-backend

# 停用開機自動啟動
sudo systemctl disable tetris-dual-backend

# 查看日誌
sudo journalctl -u tetris-dual-backend -f
```

---

## 效能調優

### Worker 數量建議

```ini
# 公式：workers = (2 × CPU 核心數) + 1
# 你的設定：-w 8（適合 3-4 核心 CPU）

# 檢查 CPU 核心數
nproc

# 調整 worker 數量
-w $(( $(nproc) * 2 + 1 ))
```

### 記憶體考量

每個 worker 約佔用 50-100 MB：
- 8 workers ≈ 400-800 MB
- 確保有足夠記憶體

```bash
# 檢查記憶體使用
free -h

# 監控 worker 記憶體
ps aux | grep gunicorn
```

### Timeout 設定

```ini
# 適合快速 API
--timeout 30

# 有複雜查詢
--timeout 120

# 有長時間處理
--timeout 300
```

---

## 監控和告警

### 設定 Logrotate

創建 `/etc/logrotate.d/tetris-backend`：

```
/var/log/uvicorn/tetris-game-*.log {
    daily
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 ai-tracks-tetris-game ai-tracks-tetris-game
    sharedscripts
    postrotate
        systemctl reload tetris-dual-backend > /dev/null 2>&1 || true
    endscript
}
```

### 健康檢查腳本

創建 `/usr/local/bin/tetris-healthcheck.sh`：

```bash
#!/bin/bash
HEALTH_URL="http://127.0.0.1:8098/health"

if ! curl -f -s -o /dev/null "$HEALTH_URL"; then
    echo "Health check failed!"
    systemctl restart tetris-dual-backend
    # 發送告警（可選）
    # mail -s "Tetris Backend Down" admin@example.com
fi
```

設定 cron：
```bash
# 每 5 分鐘檢查一次
*/5 * * * * /usr/local/bin/tetris-healthcheck.sh
```

---

## 升級和更新

```bash
# 1. 停止服務
sudo systemctl stop tetris-dual-backend

# 2. 更新代碼
cd /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/backend
git pull

# 3. 更新依賴
uv sync

# 4. 重新載入 systemd（如果 service 檔案有變更）
sudo systemctl daemon-reload

# 5. 啟動服務
sudo systemctl start tetris-dual-backend

# 6. 檢查狀態
sudo systemctl status tetris-dual-backend
```

---

## 快速參考

| 問題 | 檢查命令 |
|------|----------|
| 服務狀態 | `sudo systemctl status tetris-dual-backend` |
| 實時日誌 | `sudo journalctl -u tetris-dual-backend -f` |
| 錯誤日誌 | `tail -f /var/log/uvicorn/tetris-game-error.log` |
| uv 位置 | `which uv` |
| 手動測試 | `uv run gunicorn app.main:app -w 2 -k uvicorn.workers.UvicornWorker -b 127.0.0.1:8098` |
| 重啟服務 | `sudo systemctl restart tetris-dual-backend` |

---

**記住關鍵點：使用 `uv run` 而不是直接路徑！**








