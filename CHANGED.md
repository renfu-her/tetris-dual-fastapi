# Change Log

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

