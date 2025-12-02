# Quick Start Guide - Tetris Dual Backend

## 快速啟動指南

### 1️⃣ 創建 MySQL 資料庫

**選項 A - 使用 SQL 腳本 (推薦):**
```bash
mysql -u root < create_database.sql
```

**選項 B - 手動創建:**
```bash
mysql -u root
```
然後執行:
```sql
CREATE DATABASE `tetris-dual` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EXIT;
```

**選項 C - 如果有密碼:**
```bash
mysql -u root -p < create_database.sql
# 輸入密碼
```

### 2️⃣ 安裝依賴 (已完成)

```bash
cd backend
uv sync
```

✅ 已使用 Python 3.12.12  
✅ 所有依賴已安裝

### 3️⃣ 啟動伺服器

**Windows:**
```bash
cd backend
start.bat
```

**Linux/Mac:**
```bash
cd backend
./start.sh
```

**或手動啟動:**
```bash
cd backend
uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 4️⃣ 驗證運行

開啟瀏覽器訪問:

- 🏠 **主頁**: http://localhost:8000/
- 💚 **健康檢查**: http://localhost:8000/health
- 📚 **API 文檔**: http://localhost:8000/docs

應該看到:
```json
{
  "status": "online",
  "message": "Tetris Dual Backend API",
  "version": "1.0.0",
  "docs": "/docs"
}
```

### 5️⃣ 測試 API

**儲存分數:**
```bash
curl -X POST "http://localhost:8000/api/scores" \
  -H "Content-Type: application/json" \
  -d "{\"player_name\":\"Test\",\"score\":1000,\"lines\":10,\"mode\":\"1P\"}"
```

**查看排行榜:**
```bash
curl "http://localhost:8000/api/leaderboard"
```

---

## 常見問題

### ❌ 資料庫連接失敗

**錯誤:** `Unknown database 'tetris-dual'`  
**解決:** 執行步驟 1 創建資料庫

**錯誤:** `Access denied for user 'root'`  
**解決:** 在 `.env` 中設定正確的密碼:
```
DATABASE_URL=mysql+pymysql://root:YOUR_PASSWORD@localhost/tetris-dual
```

### ❌ Port 被占用

**錯誤:** `Address already in use`  
**解決:** 更改 port:
```bash
uv run uvicorn app.main:app --port 8001
```

### ✅ 啟動成功標誌

看到以下訊息表示成功:
```
INFO:     Started server process [12345]
INFO:     Waiting for application startup.
>>> Starting up Tetris Dual Backend...
>>> Database initialized successfully
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8000
```

---

## 下一步

1. ✅ 確認後端運行在 http://localhost:8000
2. ✅ 查看 API 文檔: http://localhost:8000/docs
3. ✅ 啟動前端 (在 frontend 目錄):
   ```bash
   cd frontend
   npm run dev
   # 或
   pnpm dev
   ```
4. ✅ 開始遊戲！

---

## 文檔參考

- 📖 [README.md](README.md) - 專案概述
- 🔧 [SETUP.md](SETUP.md) - 詳細設置指南
- 📋 [API_REFERENCE.md](API_REFERENCE.md) - API 完整文檔

