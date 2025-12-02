# Tetris Dual - 完整實作總結

## 🎯 專案概述

雙人俄羅斯方塊遊戲，支援 1-2 人模式，使用 FastAPI 後端 + React 前端，MySQL 資料庫儲存遊戲記錄。

---

## 📊 資料架構

### 資料庫結構

```
games 表 (單一遊戲記錄)
├── id (INT PRIMARY KEY)
├── mode (ENUM: '1P', '2P')
├── player1_name (VARCHAR 100)
├── player1_score (INT)
├── player1_lines (INT)
├── player2_name (VARCHAR 100, nullable)
├── player2_score (INT, nullable)
├── player2_lines (INT, nullable)
├── winner (INT, nullable: 1, 2, or NULL)
└── created_at (TIMESTAMP)
```

**設計理念：**
- ✅ 一場遊戲一筆記錄
- ✅ Player 2 欄位可為 null（1P 模式）
- ✅ Winner 欄位記錄勝負關係
- ✅ 完整的資料關聯性

---

## 🔄 資料流程

### 1P 模式

```
前端 (React)                    後端 (FastAPI)              資料庫 (MySQL)
    │                                │                          │
    │  遊戲結束                        │                          │
    │  ↓                              │                          │
    │  提示輸入名字                     │                          │
    │  ↓                              │                          │
    │  POST /api/games  ──────────→  │                          │
    │  {                              │  驗證資料                  │
    │    mode: "1P",                  │  ↓                        │
    │    player1: {...},              │  INSERT INTO games  ──→  │
    │    player2: null,               │                          │
    │    winner: null                 │  ← 回傳結果               │
    │  }                              │                          │
    │  ← 201 Created ─────────────    │                          │
    │  ↓                              │                          │
    │  更新排行榜                        │                          │
    │  GET /api/leaderboard  ──────→  │  SELECT FROM games ───→  │
    │  ← 排行榜資料  ──────────────    │  ← 查詢結果               │
    │  ↓                              │                          │
    │  顯示排行榜                        │                          │
```

### 2P 模式

```
前端 (React)                    後端 (FastAPI)              資料庫 (MySQL)
    │                                │                          │
    │  遊戲結束（判斷勝負）               │                          │
    │  ↓                              │                          │
    │  提示 Player 1 輸入名字            │                          │
    │  → 儲存到 pendingGame.player1    │                          │
    │  ↓                              │                          │
    │  提示 Player 2 輸入名字            │                          │
    │  → 儲存到 pendingGame.player2    │                          │
    │  ↓                              │                          │
    │  兩者都有資料                       │                          │
    │  ↓                              │                          │
    │  POST /api/games  ──────────→  │                          │
    │  {                              │  驗證資料                  │
    │    mode: "2P",                  │  ↓                        │
    │    player1: {...},              │  INSERT INTO games  ──→  │
    │    player2: {...},              │  (包含雙方資料)              │
    │    winner: 1 or 2               │                          │
    │  }                              │  ← 回傳結果               │
    │  ← 201 Created ─────────────    │                          │
    │  ↓                              │                          │
    │  清空 pendingGame                 │                          │
    │  更新排行榜                        │                          │
```

---

## 🚀 快速開始

### 1. 建立資料庫

```bash
cd backend
mysql -u root < create_database.sql
```

### 2. 啟動後端

```bash
cd backend
uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

驗證: http://localhost:8000/docs

### 3. 啟動前端

```bash
cd frontend
npm run dev
```

訪問: http://localhost:5173

---

## 📡 API 端點

### POST /api/games

儲存遊戲記錄

**1P 範例：**
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

**2P 範例：**
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

### GET /api/leaderboard

**參數：**
- `mode`: "1P" | "2P" | "all" (default: "all")
- `limit`: 1-100 (default: 10)

**回應：** 扁平化的玩家表現列表
```json
[
  {
    "game_id": 1,
    "player_name": "Alice",
    "score": 2000,
    "lines": 20,
    "mode": "2P",
    "is_winner": true,
    "created_at": "2024-12-02T22:00:00Z"
  },
  {
    "game_id": 1,
    "player_name": "Bob",
    "score": 1800,
    "lines": 18,
    "mode": "2P",
    "is_winner": false,
    "created_at": "2024-12-02T22:00:00Z"
  }
]
```

### GET /api/leaderboard/stats

**回應：**
```json
{
  "total_games": 100,
  "total_1p_games": 60,
  "total_2p_games": 40,
  "highest_score": 5000,
  "average_score": 1250.5,
  "total_lines_cleared": 1500
}
```

---

## 📁 檔案結構

```
tetris-dual/
├── backend/
│   ├── app/
│   │   ├── main.py           # FastAPI 應用
│   │   ├── database.py       # 資料庫連接
│   │   ├── models.py         # Game 模型
│   │   ├── schemas.py        # Pydantic schemas
│   │   ├── crud.py           # CRUD 操作
│   │   └── routers/
│   │       ├── scores.py     # 遊戲記錄 API
│   │       └── leaderboard.py # 排行榜 API
│   ├── pyproject.toml        # uv 配置
│   ├── .env                  # 環境變數
│   ├── .python-version       # Python 3.12.12
│   ├── create_database.sql  # 建庫腳本
│   ├── README.md            # 說明文檔
│   ├── SETUP.md             # 設定指南
│   ├── QUICKSTART.md        # 快速開始
│   ├── API_CHANGES.md       # API 變更
│   ├── API_REFERENCE.md     # API 參考
│   └── MIGRATION.md         # 遷移指南
│
├── frontend/
│   ├── App.tsx              # 主應用
│   ├── services/
│   │   └── leaderboardService.ts # API 整合
│   ├── components/
│   │   ├── TetrisBoard.tsx
│   │   ├── Leaderboard.tsx
│   │   └── NextPiece.tsx
│   ├── hooks/
│   │   └── useTetris.ts
│   ├── types.ts
│   ├── constants.ts
│   ├── package.json
│   ├── README.md
│   └── TESTING.md           # 測試指南
│
├── CHANGED.md               # 更新日誌
└── SUMMARY.md              # 本文檔
```

---

## 🔧 技術棧

### Backend
- **Python**: 3.12.12
- **FastAPI**: Modern web framework
- **SQLAlchemy**: ORM
- **MySQL**: Database
- **uv**: Package manager
- **Pydantic**: Data validation

### Frontend
- **React**: UI framework
- **TypeScript**: Type safety
- **Vite**: Build tool
- **Tailwind CSS**: Styling

---

## ✨ 主要特色

### 資料完整性
- ✅ 單一遊戲記錄，資料關聯性強
- ✅ 勝負關係明確記錄
- ✅ 支援 1P 和 2P 模式

### API 設計
- ✅ RESTful API
- ✅ 自動生成文檔 (Swagger UI)
- ✅ 完整的資料驗證
- ✅ CORS 支援

### 前端整合
- ✅ 自動 fallback 到 localStorage
- ✅ 詳細的 Console log
- ✅ 流暢的使用者體驗
- ✅ 響應式設計

### 開發體驗
- ✅ 完整的文檔
- ✅ 詳細的測試指南
- ✅ 簡單的設定流程
- ✅ 清楚的錯誤訊息

---

## 📚 文檔導覽

| 文檔 | 用途 | 讀者 |
|------|------|------|
| [SUMMARY.md](SUMMARY.md) | 整體概覽 | 所有人 |
| [backend/QUICKSTART.md](backend/QUICKSTART.md) | 快速開始 | 開發者 |
| [backend/SETUP.md](backend/SETUP.md) | 詳細設定 | 開發者 |
| [backend/README.md](backend/README.md) | 專案說明 | 開發者 |
| [backend/API_REFERENCE.md](backend/API_REFERENCE.md) | API 文檔 | 前端開發者 |
| [backend/API_CHANGES.md](backend/API_CHANGES.md) | API 變更 | 維護者 |
| [backend/MIGRATION.md](backend/MIGRATION.md) | 資料庫遷移 | 運維人員 |
| [frontend/TESTING.md](frontend/TESTING.md) | 測試指南 | QA/開發者 |
| [CHANGED.md](CHANGED.md) | 更新日誌 | 所有人 |

---

## 🎮 使用流程

### 玩家視角

1. **開啟遊戲** → http://localhost:5173
2. **選擇模式** → 1 PLAYER 或 2 PLAYERS
3. **開始遊戲** → 使用鍵盤控制
4. **遊戲結束** → 輸入名字
5. **查看排行榜** → 自動滾動顯示

### 開發者視角

1. **查看 API 文檔** → http://localhost:8000/docs
2. **測試 API** → 使用 Swagger UI
3. **查看資料庫** → `mysql -u root tetris-dual`
4. **檢查 Console** → 瀏覽器開發工具
5. **監控請求** → Network 標籤

---

## 🔍 除錯資源

### Console Logs

前端會輸出：
- `Saved Player 1 data:` 
- `Saved Player 2 data:`
- `Submitting game:`
- `Game saved successfully!`
- `Failed to save game:`

### API 端點測試

```bash
# 健康檢查
curl http://localhost:8000/health

# 儲存遊戲
curl -X POST http://localhost:8000/api/games \
  -H "Content-Type: application/json" \
  -d '{"mode":"1P","player1":{"name":"Test","score":1000,"lines":10},"player2":null,"winner":null}'

# 查看排行榜
curl http://localhost:8000/api/leaderboard

# 查看統計
curl http://localhost:8000/api/leaderboard/stats
```

### 資料庫查詢

```sql
-- 查看所有遊戲
SELECT * FROM games ORDER BY created_at DESC LIMIT 10;

-- 查看 2P 遊戲
SELECT * FROM games WHERE mode = '2P';

-- 統計
SELECT mode, COUNT(*) as count, AVG(player1_score) as avg_score
FROM games GROUP BY mode;
```

---

## 🎯 下一步

1. ✅ 建立資料庫
2. ✅ 啟動後端
3. ✅ 啟動前端
4. ✅ 測試 1P 模式
5. ✅ 測試 2P 模式
6. ✅ 查看排行榜
7. ✅ 檢查統計資訊

**準備就緒！開始玩遊戲吧！** 🎮🎉

