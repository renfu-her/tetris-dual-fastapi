# Tetris Dual API Reference

## Base URL

```
http://localhost:8000
```

## Endpoints

### 1. Root / Health Check

#### GET `/`
獲取 API 狀態和基本資訊。

**Response:**
```json
{
  "status": "online",
  "message": "Tetris Dual Backend API",
  "version": "1.0.0",
  "docs": "/docs"
}
```

#### GET `/health`
健康檢查端點。

**Response:**
```json
{
  "status": "healthy",
  "service": "tetris-dual-backend"
}
```

---

### 2. Scores (分數管理)

#### POST `/api/scores`
儲存新的遊戲分數記錄。

**Request Body:**
```json
{
  "player_name": "string (1-100 characters)",
  "score": "integer (>= 0)",
  "lines": "integer (>= 0)",
  "mode": "1P | 2P"
}
```

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/scores" \
  -H "Content-Type: application/json" \
  -d '{
    "player_name": "Alice",
    "score": 2500,
    "lines": 25,
    "mode": "1P"
  }'
```

**Success Response (201 Created):**
```json
{
  "id": 1,
  "player_name": "Alice",
  "score": 2500,
  "lines": 25,
  "mode": "1P",
  "created_at": "2024-12-02T10:30:00+00:00"
}
```

**Error Response (500 Internal Server Error):**
```json
{
  "detail": "Failed to save score: [error message]"
}
```

---

### 3. Leaderboard (排行榜)

#### GET `/api/leaderboard`
獲取排行榜資料，可依模式篩選。

**Query Parameters:**
- `mode` (optional): 遊戲模式篩選
  - `all` (預設): 顯示所有模式
  - `1P`: 只顯示單人模式
  - `2P`: 只顯示雙人模式
- `limit` (optional): 返回結果數量
  - 範圍: 1-100
  - 預設: 10

**Example Requests:**

獲取前 10 名（所有模式）:
```bash
curl "http://localhost:8000/api/leaderboard"
```

獲取單人模式前 5 名:
```bash
curl "http://localhost:8000/api/leaderboard?mode=1P&limit=5"
```

獲取雙人模式前 20 名:
```bash
curl "http://localhost:8000/api/leaderboard?mode=2P&limit=20"
```

**Success Response (200 OK):**
```json
[
  {
    "id": 5,
    "player_name": "Alice",
    "score": 5000,
    "lines": 50,
    "mode": "1P",
    "created_at": "2024-12-02T14:30:00+00:00"
  },
  {
    "id": 3,
    "player_name": "Bob",
    "score": 4500,
    "lines": 45,
    "mode": "2P",
    "created_at": "2024-12-02T13:15:00+00:00"
  }
]
```

#### GET `/api/leaderboard/stats`
獲取所有遊戲的統計資訊。

**Example Request:**
```bash
curl "http://localhost:8000/api/leaderboard/stats"
```

**Success Response (200 OK):**
```json
{
  "total_games": 150,
  "highest_score": 8500,
  "average_score": 2345.67,
  "total_lines_cleared": 3500
}
```

---

## Data Models

### Score Record

| Field | Type | Description |
|-------|------|-------------|
| id | integer | 唯一識別碼 (自動生成) |
| player_name | string | 玩家名稱 (1-100 字元) |
| score | integer | 遊戲分數 (非負整數) |
| lines | integer | 消除的行數 (非負整數) |
| mode | enum | 遊戲模式 ("1P" 或 "2P") |
| created_at | datetime | 記錄創建時間 (ISO 8601 格式) |

---

## Error Handling

所有端點都遵循標準的 HTTP 狀態碼:

- `200 OK`: 成功獲取資料
- `201 Created`: 成功創建新資源
- `400 Bad Request`: 請求格式錯誤或驗證失敗
- `422 Unprocessable Entity`: 請求資料驗證錯誤
- `500 Internal Server Error`: 伺服器內部錯誤

**Error Response Format:**
```json
{
  "detail": "Error message description"
}
```

---

## Rate Limiting

目前沒有實施速率限制。在生產環境中，建議加入適當的速率限制中間件。

---

## CORS Configuration

API 已配置 CORS 以允許以下來源:
- `http://localhost:5173`
- `http://127.0.0.1:5173`

可在 `.env` 檔案中修改 `CORS_ORIGINS` 來調整。

---

## Interactive Documentation

訪問以下 URL 獲取互動式 API 文檔:

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

這些介面提供:
- 完整的 API 規格
- 互動式測試工具
- Schema 定義
- 範例請求和回應

---

## Frontend Integration

### JavaScript/TypeScript Example

```typescript
// Save score
async function saveScore(playerName: string, score: number, lines: number, mode: '1P' | '2P') {
  const response = await fetch('http://localhost:8000/api/scores', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      player_name: playerName,
      score: score,
      lines: lines,
      mode: mode,
    }),
  });
  
  if (!response.ok) {
    throw new Error('Failed to save score');
  }
  
  return await response.json();
}

// Get leaderboard
async function getLeaderboard(mode: '1P' | '2P' | 'all' = 'all', limit: number = 10) {
  const response = await fetch(
    `http://localhost:8000/api/leaderboard?mode=${mode}&limit=${limit}`
  );
  
  if (!response.ok) {
    throw new Error('Failed to fetch leaderboard');
  }
  
  return await response.json();
}

// Get stats
async function getStats() {
  const response = await fetch('http://localhost:8000/api/leaderboard/stats');
  
  if (!response.ok) {
    throw new Error('Failed to fetch stats');
  }
  
  return await response.json();
}
```

---

## Database Schema

```sql
CREATE TABLE scores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    player_name VARCHAR(100) NOT NULL,
    score INT NOT NULL,
    lines INT NOT NULL,
    mode ENUM('1P', '2P') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_score (score DESC),
    INDEX idx_mode (mode),
    INDEX idx_score_mode_created (score DESC, mode, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## Version History

- **v1.0.0** (2024-12-02): Initial release
  - Score saving endpoint
  - Leaderboard with filtering
  - Statistics endpoint
  - CORS support
  - MySQL database integration

