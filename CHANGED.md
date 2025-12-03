# Change Log

## 2025-12-03 - Update 12: Keyboard Control Customization

### 鍵盤控制調整 (Keyboard Control Adjustments)

**修改內容：**

**1P (Player 1) 控制鍵：**
- Hard Drop (快速到底): `Space` → `S`
- Soft Drop (軟下降): `S` → `X` (避免與 Hard Drop 衝突)
- Move Left: `A` (保持不變)
- Move Right: `D` (保持不變)
- Rotate (旋轉): `W` (保持不變)

**2P (Player 2) 控制鍵：**
- Move Left (左移): `Arrow Left` → `J`
- Move Right (右移): `Arrow Right` → `L`
- Rotate (旋轉): `Arrow Up` → `I`
- Hard Drop (快速到底): `Enter/NumpadEnter` → `,` (逗號)
- Soft Drop (軟下降): `Arrow Down` → `K` (保持一致性)

**更新檔案：**
- `frontend/constants.ts` - 更新 INPUT_P1 和 INPUT_P2 鍵盤對應

**控制鍵摘要表：**

| 功能 | 1P | 2P |
|------|----|----|
| 左移 | A | J |
| 右移 | D | L |
| 旋轉 | W | I |
| 軟下降 | X | K |
| 快速到底 | S | , |

**Date:** 2025-12-03

---

## 2024-12-03 - Update 11: Clean UI - 移除 API 狀態組件

### 簡化使用者介面

**移除內容：**
- ❌ ApiStatus 組件（右上角的 API 狀態指示器）
- ❌ ApiInfo 組件和按鈕（API 資訊彈窗）

**原因：**
- 使用 Nginx 反向代理後，API 和前端在同一域名下
- 不需要顯示 API 連接狀態
- 簡化使用者介面，專注於遊戲本身

**更新檔案：**
- `frontend/App.tsx` - 移除 ApiStatus 和 ApiInfo 相關代碼

**保留的組件：**
- ✅ ApiStatus.tsx 和 ApiInfo.tsx 文件仍保留（以備需要時使用）
- ✅ 可以隨時重新添加

---

## 2024-12-03 - Update 10: No CORS Setup (使用 Nginx 反向代理)

### 無需 CORS 的完美方案

**核心理念：**
通過 Nginx 反向代理，讓前端和後端使用同一個域名，這樣就是**同源請求**，完全不需要處理 CORS！

**架構設計：**
```
https://tetris-game.ai-tracks.com/       → 前端靜態文件
https://tetris-game.ai-tracks.com/api/   → 後端 API (反向代理到 127.0.0.1:8098)
```

**更新內容：**
- ✅ 後端根據環境自動決定是否啟用 CORS
  - 生產環境（ENV=production）：停用 CORS
  - 開發環境（ENV=development）：啟用 CORS
- ✅ 創建完整的無 CORS 設置指南
- ✅ Nginx 反向代理配置
- ✅ 前端使用相對路徑調用 API

**更新檔案：**
- `backend/app/main.py` - 智能 CORS 配置
- `backend/NO_CORS_SETUP.md` - 完整設置指南

**優勢：**
1. ✨ **無需 CORS**：同源請求，不觸發 CORS 檢查
2. 🔒 **更安全**：不需要配置 `Access-Control-Allow-Origin`
3. 🚀 **更快**：沒有預檢請求（OPTIONS）
4. 🎯 **更簡單**：減少配置複雜度
5. 🌐 **統一域名**：所有流量通過一個域名

**關鍵配置：**

後端 `.env`：
```env
ENV=production  # 生產環境不啟用 CORS
```

前端 `.env`：
```env
VITE_API_BASE_URL=/api  # 使用相對路徑
```

Nginx 配置：
```nginx
location /api/ {
    proxy_pass http://127.0.0.1:8098/api/;
    proxy_set_header Host $host;
    # ... 其他代理設置
}
```

---

## 2024-12-03 - Update 9: Production Deployment Tools & Guides

### 生產環境部署工具和完整指南

**新增功能：**
- ✅ Frontend 自動部署腳本
- ✅ 完整的 Nginx 配置指南和示例
- ✅ 生產環境修復檢查清單
- ✅ 一步步的問題排除指南

**新增檔案：**
- `frontend/deploy.sh` - 前端自動構建和部署腳本
- `NGINX_CONFIG.md` - Nginx 完整配置指南
- `PRODUCTION_FIX_CHECKLIST.md` - 生產環境修復檢查清單

**功能特點：**

**1. Frontend 部署腳本 (`frontend/deploy.sh`)**
   - 自動檢查環境配置
   - 安裝依賴
   - 構建生產版本
   - 檢查構建輸出
   - 顯示部署說明（rsync/scp/git）

**2. Nginx 配置指南 (`NGINX_CONFIG.md`)**
   - 完整的 Nginx 配置示例
   - HTTP 到 HTTPS 重定向
   - 靜態文件服務
   - API 反向代理
   - Gzip 壓縮
   - 緩存設置
   - 安全頭部
   - 常見問題解決

**3. 生產環境修復清單 (`PRODUCTION_FIX_CHECKLIST.md`)**
   - 後端服務修復步驟
   - 前端部署步驟
   - Nginx 配置檢查
   - 完整驗證流程
   - 診斷工具使用
   - 檢查清單
   - 問題收集指南

**使用方式：**

```bash
# 1. 本地構建前端
cd frontend
./deploy.sh

# 2. 部署到服務器
rsync -avz dist/ user@server:/path/to/dist/

# 3. 在服務器上檢查狀態
cd backend
./check-production.sh

# 4. 如有問題，查看修復清單
cat PRODUCTION_FIX_CHECKLIST.md
```

**解決的問題：**
- ❌ 404 Not Found (靜態文件)
- ❌ API Offline (後端連接)
- ❌ CORS 錯誤
- ❌ 502 Bad Gateway
- ❌ 權限問題

---

## 2024-12-03 - Update 8: Final CORS Configuration

### 最終 CORS 配置 (Final CORS Configuration)

**修正內容：**
- ✅ 允許生產環境：`https://tetris-game.ai-tracks.com`
- ✅ 允許本地開發：`http://localhost:3000`, `http://localhost:5173`, `http://localhost:8098`
- ✅ 開發模式自動添加 127.0.0.1 變體
- ✅ 更新所有相關腳本和文檔

**CORS 允許的來源：**
```
生產環境：
- https://tetris-game.ai-tracks.com

開發環境：
- http://localhost:3000
- http://localhost:5173
- http://localhost:8098
- http://127.0.0.1:3000
- http://127.0.0.1:5173
- http://127.0.0.1:8098
```

**更新檔案：**
- `backend/app/main.py` - CORS 配置
- `backend/fix-cors.sh` - 自動修復腳本
- `backend/.env.template` - 環境變數模板

**部署到生產環境：**
```bash
cd /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/backend
git pull
sudo systemctl restart tetris-dual-backend.service
```

---

## 2024-12-03 - Update 7: Production Troubleshooting & CORS Fix

### 生產環境診斷工具 + CORS 配置修復

**新增功能：**
- ✅ 快速診斷腳本 - 立即找出問題
- ✅ 生產環境狀態檢查
- ✅ 完整的修復指南
- ✅ 常見問題解決方案
- ✅ **CORS 配置自動修復**
- ✅ CORS 詳細配置指南

**新增檔案：**
- `backend/QUICK_FIX.md` - 500 錯誤快速修復指南
- `backend/check-production.sh` - 生產環境快速檢查腳本
- `backend/fix-cors.sh` - CORS 配置自動修復腳本
- `backend/CORS_SETUP.md` - CORS 配置完整指南

**更新檔案：**
- `backend/app/main.py` - 改進 CORS 配置，增加日誌輸出

**使用方式：**

**在生產服務器上執行：**

```bash
# 快速檢查所有狀態
cd /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/backend
chmod +x check-production.sh
./check-production.sh

# 詳細診斷
./diagnose-service.sh

# 查看修復指南
cat QUICK_FIX.md
```

**檢查項目：**
1. ✓ MySQL 服務狀態
2. ✓ 後端服務狀態  
3. ✓ 端口監聽狀況（8098）
4. ✓ 本地 API 響應
5. ✓ 外部訪問測試
6. ✓ Nginx 狀態和配置
7. ✓ 日誌目錄權限
8. ✓ 最近錯誤日誌

**常見修復命令：**

```bash
# 啟動服務
sudo systemctl start tetris-dual-backend.service

# 重啟服務
sudo systemctl restart tetris-dual-backend.service

# 查看實時日誌
sudo journalctl -u tetris-dual-backend.service -f

# 重新安裝依賴
cd backend && uv sync

# 修復權限
sudo chown -R ai-tracks-tetris-game:ai-tracks-tetris-game /var/log/uvicorn
```

---

## 2024-12-03 - Update 6: API Status Indicator & Info Component

### 即時 API 狀態指示器 (Real-time API Status Indicator)

**新增功能：**
- ✅ **即時狀態顯示**：頁面右上角直接顯示 API 連接狀態
- ✅ **自動檢測**：每 30 秒自動檢查 API 是否在線
- ✅ **視覺指示**：
  - 🟢 綠色 = API Online（正常連接）
  - 🔴 紅色 = API Offline（連接失敗）
  - 🟡 黃色 = Checking（檢查中）
- ✅ **版本顯示**：連接成功時顯示 API 版本號
- ✅ **懸停提示**：滑鼠移到狀態上可看到完整 API URL

**新增檔案：**
- `frontend/components/ApiStatus.tsx` - 即時 API 狀態指示器
- `frontend/components/ApiInfo.tsx` - 詳細 API 資訊組件

**更新檔案：**
- `frontend/App.tsx` - 添加 ApiStatus 組件在右上角

**功能特點：**
- 📡 **即時狀態檢查**：自動獲取 API 狀態和健康檢查
- 🌐 **連接資訊**：顯示當前使用的 API URL
- 📋 **端點列表**：列出所有可用的 API 端點（GET/POST）
- 📚 **文檔連結**：快速訪問 Swagger UI 和 ReDoc
- ⚙️ **環境資訊**：顯示環境變數配置提示
- ❌ **錯誤診斷**：連接失敗時提供清晰的錯誤訊息和解決建議

**使用方式：**
1. 在主選單點擊 "🔌 API Info" 按鈕
2. 查看 API 連接狀態和端點資訊
3. 點擊文檔連結可以打開完整的 API 文檔

**顯示內容：**
- API 狀態（online/offline）
- 服務版本號
- 健康檢查結果
- API Base URL 和 Root URL
- 所有可用端點及其用途
- Swagger UI 和 ReDoc 文檔連結
- 環境變數設定說明

**技術亮點：**
- 使用 React Hooks（useState, useEffect）
- 優雅的 Modal 彈窗設計
- 深色主題 UI，與遊戲風格一致
- 完整的錯誤處理機制
- 自動從環境變數讀取 API URL

---

## 2024-12-03 - Update 5: Environment Variable Configuration for Frontend

### 前端環境變數配置 (Frontend Environment Variable Configuration)

**新增功能：**
- ✅ API URL 現在可以透過環境變數設定
- ✅ 支援開發環境和生產環境的不同配置
- ✅ 創建環境變數模板文件

**新增/更新檔案：**
- `frontend/env.template` - 環境變數模板文件（新增）
- `frontend/vite-env.d.ts` - TypeScript 環境變數類型定義（新增）
- `frontend/services/leaderboardService.ts` - 更新為使用環境變數中的 API URL
- `frontend/vite.config.ts` - 更新配置以支援 VITE_API_BASE_URL
- `frontend/README.md` - 更新使用說明

**環境變數設定：**
```bash
# 生產環境
VITE_API_BASE_URL=https://tetris-game.ai-tracks.com/api

# 開發環境
VITE_API_BASE_URL=http://localhost:8000/api
```

**使用方式：**
1. 複製 `env.template` 為 `.env`：
   ```bash
   cd frontend
   cp env.template .env
   ```
2. 編輯 `.env` 設定你的 API URL
3. 啟動開發服務器：
   ```bash
   pnpm dev
   ```

**技術細節：**
- 使用 Vite 的環境變數系統（需要 `VITE_` 前綴）
- 在 `vite.config.ts` 中配置環境變數
- 提供預設值 fallback 機制
- 完整的 TypeScript 類型支援

**好處：**
- 🎯 更容易切換開發/生產環境
- 🔒 敏感設定不需要寫死在代碼中
- 📦 部署時更靈活
- 🛠️ 開發體驗更好

---

## 2024-12-02 - Update 4: Production Deployment with Gunicorn

### Gunicorn 支援

**新增功能：**
- ✅ Gunicorn + Uvicorn Workers 配置
- ✅ 生產環境啟動腳本
- ✅ 完整的 Gunicorn 配置檔案
- ✅ 生產部署指南

**新增檔案：**
- `backend/gunicorn.conf.py` - Gunicorn 配置
- `backend/start-prod.sh` - Linux/Mac 生產啟動腳本
- `backend/start-prod.bat` - Windows 生產啟動腳本
- `backend/PRODUCTION.md` - 生產部署完整指南

**更新檔案：**
- `backend/pyproject.toml` - 新增 gunicorn 依賴
- `backend/.env.example` - 新增 Gunicorn 環境變數
- `backend/README.md` - 新增生產模式說明

**配置特點：**
- 自動計算 worker 數量（CPU * 2 + 1）
- Uvicorn worker class for ASGI support
- 完整的日誌配置
- 生產級別的性能優化

**使用方式：**

開發模式：
```bash
./start.sh  # Uvicorn with reload
```

生產模式：
```bash
./start-prod.sh  # Gunicorn with multiple workers
```

**部署選項：**
- Systemd service
- Docker container
- Nginx reverse proxy
- Supervisor process manager

---

## 2024-12-02 - Update 3: Frontend API Integration Fixes

### 前端整合修正

**問題：** 2P 模式只提示贏家輸入名字，無法收集雙方完整資料。

**解決：**
- ✅ 2P 模式現在提示**兩個玩家**都輸入名字
- ✅ 贏家顯示特殊提示訊息："WINS!"
- ✅ 完整收集雙方資料後才送出 API 請求
- ✅ 加入詳細的 Console log 便於除錯

**更新檔案：**
- `frontend/App.tsx` - 改進 handleEndGame，雙方都提示輸入
- `frontend/services/leaderboardService.ts` - 加入 console.log
- `frontend/TESTING.md` - 新增測試指南

**測試流程：**
1. 玩 2P 模式
2. 一方先死
3. 會出現兩次提示輸入名字
4. Console 顯示完整的資料收集流程
5. 一次 POST 請求包含雙方資料

---

## 2024-12-02 - Update 2: Game-Based Recording (Single Record per Game)

### Major Architecture Change

改變資料庫結構為**單一遊戲記錄**模式，一場遊戲（1或2人）存成一筆資料。

#### Database Schema Change

**舊結構** (`scores` 表) - 每個玩家一筆記錄：
- 每個玩家的分數分開儲存
- 無法關聯同一場遊戲的兩個玩家
- 無法記錄勝負關係

**新結構** (`games` 表) - 一場遊戲一筆記錄：
```sql
CREATE TABLE games (
    id INT PRIMARY KEY AUTO_INCREMENT,
    mode ENUM('1P', '2P'),
    -- Player 1 (always present)
    player1_name VARCHAR(100),
    player1_score INT,
    player1_lines INT,
    -- Player 2 (nullable, for 2P mode)
    player2_name VARCHAR(100) NULL,
    player2_score INT NULL,
    player2_lines INT NULL,
    -- Winner indicator
    winner INT NULL,  -- 1, 2, or NULL
    created_at TIMESTAMP,
    INDEX(player1_score, mode, created_at),
    INDEX(player2_score, mode, created_at)
);
```

#### API Changes

**端點更新：**
- `POST /api/scores` → `POST /api/games`
- `GET /api/leaderboard` - 回傳格式改為扁平化的玩家表現列表

**新的請求格式：**

1P 模式：
```json
{
  "mode": "1P",
  "player1": {
    "name": "Alice",
    "score": 1500,
    "lines": 15
  },
  "player2": null,
  "winner": null
}
```

2P 模式：
```json
{
  "mode": "2P",
  "player1": {
    "name": "Alice",
    "score": 2000,
    "lines": 20
  },
  "player2": {
    "name": "Bob",
    "score": 1800,
    "lines": 18
  },
  "winner": 1
}
```

#### Updated Files

**Backend:**
- `app/models.py` - `Score` → `Game` model with player1/player2 fields
- `app/schemas.py` - New `GameCreate`, `GameResponse`, `PlayerData` schemas
- `app/crud.py` - Updated CRUD operations for game-based recording
- `app/routers/scores.py` - Renamed to handle games, new endpoint structure
- `app/routers/leaderboard.py` - Updated to flatten game records into player performances
- `create_database.sql` - Added DROP DATABASE to reset schema

**Frontend:**
- `services/leaderboardService.ts` - Updated to handle game-based API, collect both players' data for 2P mode
- `App.tsx` - Updated handleEndGame to pass player number and winner status

#### Key Benefits

✅ 完整的遊戲記錄 - 一場遊戲的所有資訊在一筆記錄中  
✅ 勝負關係明確 - 可記錄誰是贏家  
✅ 資料關聯性強 - 容易查詢同場遊戲的雙方表現  
✅ 統計更準確 - 可正確計算遊戲場次 vs 玩家人次

#### Migration Note

⚠️ 這是破壞性更新，需要重建資料庫：
```bash
mysql -u root < backend/create_database.sql
```

---

## 2024-12-02 - Update 1: FastAPI Backend Implementation

### Backend API Created

建立完整的 FastAPI backend 系統，提供俄羅斯方塊遊戲的分數記錄和排行榜功能。

#### New Backend Files

**Project Structure:**
- `backend/pyproject.toml` - uv package manager configuration
- `backend/.env.example` - Environment variables template
- `backend/.gitignore` - Git ignore rules
- `backend/README.md` - Backend documentation

**Application Files:**
- `backend/app/__init__.py` - Application package
- `backend/app/main.py` - FastAPI application with CORS configuration
- `backend/app/database.py` - MySQL database connection and session management
- `backend/app/models.py` - SQLAlchemy ORM models (Score table)
- `backend/app/schemas.py` - Pydantic schemas for validation
- `backend/app/crud.py` - Database CRUD operations

**API Routers:**
- `backend/app/routers/__init__.py` - Routers package
- `backend/app/routers/scores.py` - Score saving endpoint (POST /api/scores)
- `backend/app/routers/leaderboard.py` - Leaderboard endpoints (GET /api/leaderboard, GET /api/leaderboard/stats)

#### Database Schema

**scores table:**
- `id` (INT, PRIMARY KEY, AUTO_INCREMENT)
- `player_name` (VARCHAR(100))
- `score` (INT, indexed)
- `lines` (INT)
- `mode` (ENUM: '1P', '2P', indexed)
- `created_at` (TIMESTAMP)
- Composite index: (score, mode, created_at)

#### API Endpoints

1. **POST /api/scores** - Save game score
   - Request: `{ player_name, score, lines, mode }`
   - Response: Created score record with timestamp

2. **GET /api/leaderboard** - Get leaderboard
   - Query params: `mode` (1P/2P/all), `limit` (1-100)
   - Response: Sorted list of top scores

3. **GET /api/leaderboard/stats** - Get statistics
   - Response: Total games, highest score, average score, total lines cleared

4. **GET /** - API health check
5. **GET /health** - Service health status

#### Frontend Integration

**Modified Files:**
- `frontend/services/leaderboardService.ts`
  - Changed from localStorage to API calls
  - Added async/await for API requests
  - Kept localStorage as fallback for offline mode
  - Added `USE_API` flag to toggle between API and localStorage

- `frontend/components/Leaderboard.tsx`
  - Updated to use async getLeaderboard()
  
- `frontend/App.tsx`
  - Updated handleEndGame to await saveScore()

#### Technical Stack

- **FastAPI** - Modern Python web framework
- **SQLAlchemy** - ORM for database operations
- **MySQL** - Database (root user, no password, database: tetris-dual)
- **uv** - Fast Python package manager
- **Pydantic** - Data validation
- **CORS** - Configured for localhost:5173

#### Features

- ✅ 1-2 player game support
- ✅ Score recording with player name, score, lines, and mode
- ✅ Leaderboard with mode filtering (1P, 2P, or all)
- ✅ Game statistics endpoint
- ✅ CORS enabled for frontend integration
- ✅ Automatic database table creation
- ✅ API documentation (Swagger UI at /docs)
- ✅ Fallback to localStorage if API unavailable

#### Setup Instructions

1. Install backend dependencies:
   ```bash
   cd backend
   uv sync
   ```

2. Create MySQL database:
   ```sql
   CREATE DATABASE `tetris-dual` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```

3. Start backend server:
   ```bash
   uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

4. Access API documentation: http://localhost:8000/docs

---

