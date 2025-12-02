# API Changes - Game-Based Recording

## 重大變更說明

資料庫結構從**個別玩家記錄**改為**遊戲記錄**模式。

### 舊 vs 新結構對比

#### 舊結構（已棄用）
```
POST /api/scores
{
  "player_name": "Alice",
  "score": 1500,
  "lines": 15,
  "mode": "1P"
}
```
**問題：**
- 2P 模式需要發送兩次請求
- 無法關聯同一場遊戲的兩個玩家
- 無法記錄勝負資訊

#### 新結構（當前）
```
POST /api/games
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
**優點：**
- 一次請求儲存完整遊戲
- 明確的勝負關係
- 更好的資料完整性

---

## 新 API 端點

### POST /api/games

儲存一場遊戲記錄（1或2人）

**1P 模式範例：**
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

**2P 模式範例：**
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

**Response (201 Created):**
```json
{
  "id": 1,
  "mode": "2P",
  "player1_name": "Alice",
  "player1_score": 2000,
  "player1_lines": 20,
  "player2_name": "Bob",
  "player2_score": 1800,
  "player2_lines": 18,
  "winner": 1,
  "created_at": "2024-12-02T22:00:00Z"
}
```

### GET /api/leaderboard

獲取排行榜（扁平化的玩家表現列表）

**Query Parameters:**
- `mode`: "1P" | "2P" | "all" (default: "all")
- `limit`: 1-100 (default: 10)

**Response (200 OK):**
```json
[
  {
    "game_id": 5,
    "player_name": "Alice",
    "score": 5000,
    "lines": 50,
    "mode": "2P",
    "is_winner": true,
    "created_at": "2024-12-02T22:00:00Z"
  },
  {
    "game_id": 5,
    "player_name": "Bob",
    "score": 4500,
    "lines": 45,
    "mode": "2P",
    "is_winner": false,
    "created_at": "2024-12-02T22:00:00Z"
  }
]
```

**注意：** 
- 每場遊戲會產生 1 或 2 筆排行榜記錄（取決於模式）
- 同場遊戲的記錄有相同的 `game_id`
- `is_winner` 標示是否為獲勝者（2P 模式）

### GET /api/leaderboard/stats

獲取統計資訊

**Response (200 OK):**
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

## 資料庫 Schema

```sql
CREATE TABLE games (
    id INT PRIMARY KEY AUTO_INCREMENT,
    mode ENUM('1P', '2P') NOT NULL,
    
    -- Player 1 (always present)
    player1_name VARCHAR(100) NOT NULL,
    player1_score INT NOT NULL,
    player1_lines INT NOT NULL,
    
    -- Player 2 (nullable, only for 2P mode)
    player2_name VARCHAR(100) NULL,
    player2_score INT NULL,
    player2_lines INT NULL,
    
    -- Winner: 1, 2, or NULL (for 1P or tie)
    winner INT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_player1_score_mode (player1_score DESC, mode, created_at),
    INDEX idx_player2_score_mode (player2_score DESC, mode, created_at),
    INDEX idx_mode_created (mode, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 前端整合

### TypeScript 範例

```typescript
// Save 1P game
await fetch('http://localhost:8000/api/games', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    mode: '1P',
    player1: {
      name: 'Alice',
      score: 1500,
      lines: 15
    },
    player2: null,
    winner: null
  })
});

// Save 2P game
await fetch('http://localhost:8000/api/games', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    mode: '2P',
    player1: {
      name: 'Alice',
      score: 2000,
      lines: 20
    },
    player2: {
      name: 'Bob',
      score: 1800,
      lines: 18
    },
    winner: 1  // Alice wins
  })
});

// Get leaderboard
const response = await fetch('http://localhost:8000/api/leaderboard?mode=all&limit=10');
const leaderboard = await response.json();
```

---

## 遷移指南

### 1. 備份舊資料（如果需要）

如果你有現有資料想保留：
```bash
mysqldump -u root tetris-dual > backup.sql
```

### 2. 刪除並重建資料庫

```bash
mysql -u root < backend/create_database.sql
```

或手動執行：
```sql
DROP DATABASE IF EXISTS `tetris-dual`;
CREATE DATABASE `tetris-dual` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 3. 啟動後端

資料表會自動創建：
```bash
cd backend
uv run uvicorn app.main:app --reload
```

### 4. 驗證

訪問 http://localhost:8000/docs 確認新的 API 端點。

---

## 常見問題

### Q: 為什麼要改成這樣？

A: 新結構提供：
- 完整的遊戲記錄
- 明確的勝負關係
- 更好的資料完整性
- 更容易進行遊戲分析

### Q: 舊資料怎麼辦？

A: 這是破壞性更新。如果需要保留舊資料，請先備份，然後可以寫遷移腳本轉換格式。

### Q: 前端需要改什麼？

A: `leaderboardService.ts` 已經更新，會自動處理新的 API 格式。確保使用最新版本。

---

## 版本資訊

- **Version**: 2.0.0
- **Date**: 2024-12-02
- **Breaking Changes**: Yes
- **Migration Required**: Yes

