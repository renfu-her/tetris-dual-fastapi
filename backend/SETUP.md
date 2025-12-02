# Tetris Dual Backend - Setup Guide

完整的後端設置指南，包含資料庫配置和應用程式啟動。

## 系統需求

- **Python**: 3.11 或更高版本
- **MySQL**: 5.7 或更高版本
- **uv**: Python 套件管理工具

## 安裝步驟

### 1. 安裝 uv (如果尚未安裝)

**Linux/macOS:**
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

**Windows (PowerShell):**
```powershell
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
```

或者使用 pip:
```bash
pip install uv
```

### 2. 設置 MySQL 資料庫

#### 選項 A: 使用 MySQL CLI

```bash
mysql -u root -p
```

然後執行:
```sql
CREATE DATABASE `tetris-dual` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

#### 選項 B: 使用提供的 SQL 腳本

```bash
mysql -u root -p < init_db.sql
```

### 3. 配置環境變數

複製範例環境變數檔案:

```bash
cp .env.example .env
```

編輯 `.env` 並根據你的設置修改:

```env
# 資料庫配置
DATABASE_URL=mysql+pymysql://root:@localhost/tetris-dual

# CORS 設定（前端 URL）
CORS_ORIGINS=http://localhost:5173,http://127.0.0.1:5173

# 伺服器配置
HOST=0.0.0.0
PORT=8000
```

**注意:** 
- 如果你的 MySQL 有密碼，請修改 DATABASE_URL: `mysql+pymysql://root:YOUR_PASSWORD@localhost/tetris-dual`
- 如果資料庫名稱不同，請相應修改

### 4. 安裝依賴套件

```bash
cd backend
uv sync
```

這會自動安裝所有需要的 Python 套件:
- fastapi
- uvicorn[standard]
- sqlalchemy
- pymysql
- python-dotenv
- pydantic

### 5. 啟動後端伺服器

#### 選項 A: 使用啟動腳本 (推薦)

**Linux/macOS:**
```bash
./start.sh
```

**Windows:**
```bash
start.bat
```

#### 選項 B: 手動啟動

```bash
uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 6. 驗證安裝

伺服器啟動後，訪問以下 URL:

- **API 根目錄**: http://localhost:8000/
- **健康檢查**: http://localhost:8000/health
- **API 文檔 (Swagger)**: http://localhost:8000/docs
- **API 文檔 (ReDoc)**: http://localhost:8000/redoc

你應該看到類似以下的回應:

```json
{
  "status": "online",
  "message": "Tetris Dual Backend API",
  "version": "1.0.0",
  "docs": "/docs"
}
```

## 測試 API

### 使用 curl 測試

**儲存分數:**
```bash
curl -X POST "http://localhost:8000/api/scores" \
  -H "Content-Type: application/json" \
  -d '{
    "player_name": "TestPlayer",
    "score": 1500,
    "lines": 15,
    "mode": "1P"
  }'
```

**獲取排行榜:**
```bash
curl "http://localhost:8000/api/leaderboard?mode=all&limit=10"
```

**獲取統計資料:**
```bash
curl "http://localhost:8000/api/leaderboard/stats"
```

### 使用 Swagger UI

訪問 http://localhost:8000/docs 使用互動式 API 文檔測試所有端點。

## 常見問題

### MySQL 連接錯誤

**錯誤:** `Can't connect to MySQL server`

**解決方法:**
1. 確認 MySQL 服務正在運行
2. 檢查 `.env` 中的 DATABASE_URL 是否正確
3. 驗證資料庫用戶名和密碼

### 資料庫不存在錯誤

**錯誤:** `Unknown database 'tetris-dual'`

**解決方法:**
執行 SQL 創建資料庫:
```sql
CREATE DATABASE `tetris-dual` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### Port 已被占用

**錯誤:** `Address already in use`

**解決方法:**
1. 變更 port: `uvicorn app.main:app --port 8001`
2. 或停止占用 8000 port 的程序

### pymysql 模組錯誤

**錯誤:** `No module named 'pymysql'`

**解決方法:**
```bash
uv sync
```

## 開發模式

### 熱重載

使用 `--reload` 標誌啟動開發伺服器，程式碼變更時會自動重載:

```bash
uv run uvicorn app.main:app --reload
```

### 查看 SQL 查詢

在 `app/database.py` 中設置 `echo=True`:

```python
engine = create_engine(DATABASE_URL, echo=True)
```

### 資料庫遷移

如果你修改了 models.py 中的資料表結構，需要:

1. 停止伺服器
2. 刪除現有資料表（如果可以）
3. 重啟伺服器（會自動重建資料表）

對於正式環境，建議使用 Alembic 進行資料庫遷移。

## 生產部署

對於生產環境:

1. 移除 `--reload` 標誌
2. 使用 gunicorn 或其他 WSGI 伺服器
3. 設置適當的環境變數
4. 使用反向代理 (nginx)
5. 啟用 HTTPS

範例:
```bash
gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
```

## 技術支援

如果遇到問題:

1. 檢查伺服器日誌
2. 查看 MySQL 日誌
3. 驗證環境變數配置
4. 確認所有依賴已正確安裝

