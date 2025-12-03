# 🚀 快速部署參考

## 開發 vs 生產

| 模式 | 啟動方式 | Worker | 適用場景 |
|------|----------|--------|----------|
| **開發** | `./start.sh` | 單一 Uvicorn | 本地開發、自動重載 |
| **生產** | `./start-prod.sh` | Gunicorn + 多 Workers | 正式環境、高併發 |

---

## 一鍵啟動

### 開發模式

```bash
cd backend
./start.sh
```

特點：
- ✅ 自動重載（修改程式碼後自動重啟）
- ✅ 詳細錯誤訊息
- ✅ 單一 worker（便於除錯）

### 生產模式

```bash
cd backend
./start-prod.sh
```

特點：
- ✅ 多個 workers（充分利用 CPU）
- ✅ 自動重啟失敗的 workers
- ✅ 更好的性能和穩定性
- ✅ 生產級別的日誌

---

## 環境變數設定

編輯 `.env` 檔案：

```env
# === 開發環境 ===
DATABASE_URL=mysql+pymysql://root:@localhost/tetris-dual
CORS_ORIGINS=http://localhost:5173
HOST=0.0.0.0
PORT=8000
WORKERS=1
RELOAD=true

# === 生產環境 ===
DATABASE_URL=mysql+pymysql://tetris_user:STRONG_PASSWORD@localhost/tetris-dual
CORS_ORIGINS=https://yourdomain.com
HOST=0.0.0.0
PORT=8000
WORKERS=4
LOG_LEVEL=info
RELOAD=false
```

---

## Worker 數量建議

```
workers = (2 × CPU 核心數) + 1
```

| CPU 核心 | 建議 Workers | 範例硬體 |
|----------|--------------|----------|
| 1 | 3 | VPS 入門 |
| 2 | 5 | 小型 VPS |
| 4 | 9 | 中型伺服器 |
| 8 | 17 | 高效能伺服器 |

記憶體需求：每個 worker 約 50-100 MB

---

## 常用命令

### 檢查狀態

```bash
# 檢查伺服器是否運行
curl http://localhost:8000/health

# 查看 API 文檔
open http://localhost:8000/docs

# 查看運行中的 workers
ps aux | grep gunicorn
```

### 管理服務

```bash
# 啟動
./start-prod.sh

# 停止（Ctrl+C 或）
pkill -f "gunicorn app.main:app"

# 重啟（優雅重載，不中斷服務）
kill -HUP $(pgrep -f "gunicorn app.main:app")
```

### 查看日誌

```bash
# 實時查看日誌（如果使用 systemd）
sudo journalctl -u tetris-backend -f

# 查看錯誤日誌
tail -f /var/log/tetris/error.log

# 查看訪問日誌
tail -f /var/log/tetris/access.log
```

---

## 部署檢查清單

### 部署前

- [ ] 更新 `.env` 設定（資料庫密碼、CORS 等）
- [ ] 執行 `uv sync` 安裝依賴
- [ ] 建立資料庫：`mysql -u root < create_database.sql`
- [ ] 測試連接：`uv run python -c "from app.database import engine; engine.connect()"`

### 部署時

- [ ] 停止開發伺服器
- [ ] 啟動生產伺服器：`./start-prod.sh`
- [ ] 檢查健康狀態：`curl http://localhost:8000/health`
- [ ] 測試 API：`curl http://localhost:8000/api/leaderboard`

### 部署後

- [ ] 設定 Nginx 反向代理（如需要）
- [ ] 配置 Systemd service（自動啟動）
- [ ] 設定 SSL 憑證（HTTPS）
- [ ] 配置防火牆規則
- [ ] 設定資料庫備份
- [ ] 配置監控告警

---

## 效能優化

### 資料庫連接池

編輯 `app/database.py`：

```python
engine = create_engine(
    DATABASE_URL,
    pool_size=10,        # 基本連接數
    max_overflow=20,     # 最大額外連接
    pool_pre_ping=True,  # 連接前檢查
)
```

### Gunicorn 調優

編輯 `gunicorn.conf.py`：

```python
workers = 8              # 增加 workers
worker_connections = 2000  # 增加連接數
timeout = 30             # 調整超時
keepalive = 5            # 保持連接
```

---

## 故障排除

### 問題：502 Bad Gateway

**可能原因：**
- Backend 未啟動
- Worker 全部崩潰
- Timeout 設定太短

**解決方法：**
```bash
# 檢查是否運行
ps aux | grep gunicorn

# 重啟服務
./start-prod.sh

# 增加 timeout（gunicorn.conf.py）
timeout = 60
```

### 問題：記憶體不足

**症狀：** Workers 頻繁重啟

**解決方法：**
```bash
# 減少 workers
export WORKERS=4

# 或升級伺服器記憶體
```

### 問題：高 CPU 使用率

**解決方法：**
```bash
# 檢查慢查詢
# 添加資料庫索引
# 使用 Redis 快取
```

---

## 監控建議

### 基本監控

```bash
# CPU 和記憶體
htop

# 網路連接
netstat -an | grep 8000 | wc -l

# 磁碟使用
df -h
```

### 進階監控

使用工具：
- **Prometheus** + **Grafana**: 指標監控
- **Sentry**: 錯誤追蹤
- **New Relic** / **DataDog**: APM 監控
- **Uptime Robot**: 可用性監控

---

## 安全性檢查

- [ ] 使用強密碼
- [ ] 限制 CORS origins
- [ ] 啟用 HTTPS
- [ ] 設定防火牆
- [ ] 定期更新依賴
- [ ] 限制檔案權限（`chmod 600 .env`）
- [ ] 使用專用資料庫使用者（非 root）
- [ ] 定期備份資料庫

---

## 緊急處理

### 服務當機

```bash
# 1. 立即重啟
sudo systemctl restart tetris-backend

# 2. 檢查日誌
sudo journalctl -u tetris-backend -n 100

# 3. 查看資料庫
mysql -u root tetris-dual
```

### 資料庫損毀

```bash
# 1. 停止服務
sudo systemctl stop tetris-backend

# 2. 還原備份
gunzip < backup.sql.gz | mysql -u root tetris-dual

# 3. 重啟服務
sudo systemctl start tetris-backend
```

### 磁碟空間不足

```bash
# 清理日誌
sudo journalctl --vacuum-time=7d

# 清理舊備份
find /var/backups/tetris -mtime +30 -delete

# 檢查大檔案
du -sh /* | sort -rh | head -10
```

---

## 快速參考

| 需求 | 命令/檔案 |
|------|----------|
| 啟動開發 | `./start.sh` |
| 啟動生產 | `./start-prod.sh` |
| 健康檢查 | `curl localhost:8000/health` |
| API 文檔 | `http://localhost:8000/docs` |
| 配置檔 | `gunicorn.conf.py` |
| 環境變數 | `.env` |
| 詳細文檔 | `PRODUCTION.md` |

---

**更多資訊請參閱：**
- [PRODUCTION.md](PRODUCTION.md) - 完整生產部署指南
- [README.md](README.md) - 專案說明
- [SETUP.md](SETUP.md) - 詳細設定指南

