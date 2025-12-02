# Frontend Testing Guide - API Integration

## 測試 API 整合

### 前置準備

1. **確認後端運行：**
   ```bash
   cd backend
   uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```
   
   驗證: http://localhost:8000/health

2. **啟動前端：**
   ```bash
   cd frontend
   npm run dev
   # 或
   pnpm dev
   ```
   
   訪問: http://localhost:5173

---

## 測試案例

### ✅ 測試 1: 單人模式 (1P)

**步驟：**
1. 點擊 "1 PLAYER"
2. 玩遊戲直到 Game Over
3. 會出現提示: `Game Over! Enter name for Player 1 (Score: XXX):`
4. 輸入名字，例如 "Alice"
5. 按 OK

**預期結果：**
- 瀏覽器 Console 顯示 POST 請求到 `/api/games`
- 頁面自動滾動到排行榜
- 排行榜顯示新增的記錄
- AI 評論出現（分數相關的評語）

**驗證後端：**
```bash
# 查看 API 文檔
open http://localhost:8000/docs

# 或直接查詢
curl http://localhost:8000/api/leaderboard
```

---

### ✅ 測試 2: 雙人模式 - Player 1 先死

**步驟：**
1. 點擊 "2 PLAYERS"
2. 玩到 Player 1 Game Over (Player 2 還活著)
3. 顯示 "Player 2 Wins!"
4. 會出現兩次提示：
   - 第一次: `Game Over! Enter name for Player 1 (Score: XXX):`
   - 第二次: `Game Over! Player 2 WINS! Enter name (Score: XXX):`
5. 分別輸入兩個名字

**預期結果：**
- Console 顯示:
  ```
  Saved Player 1 data: {name: "...", score: ..., lines: ...}
  Saved Player 2 data: {name: "...", score: ..., lines: ...}
  Submitting game: {player1: {...}, player2: {...}, winner: 2}
  Game saved successfully!
  ```
- 排行榜顯示兩筆記錄（同一場遊戲）
- 獲勝者標記為 winner

**驗證資料：**
```bash
curl http://localhost:8000/api/leaderboard
```
應該看到兩筆記錄，`game_id` 相同，`is_winner` 分別為 false 和 true。

---

### ✅ 測試 3: 雙人模式 - Player 2 先死

**步驟：**
1. 點擊 "2 PLAYERS"
2. 玩到 Player 2 Game Over (Player 1 還活著)
3. 顯示 "Player 1 Wins!"
4. 輸入兩個玩家的名字

**預期結果：**
- winner 欄位 = 1
- Player 1 的 `is_winner` = true

---

### ✅ 測試 4: 雙人模式 - 同時結束

**步驟：**
1. 點擊 "2 PLAYERS"
2. 兩個玩家幾乎同時 Game Over
3. 根據分數判斷勝負

**預期結果：**
- 顯示 "Player X Wins (Score)!"
- winner 欄位設定為分數較高的玩家
- 兩筆記錄都出現在排行榜

---

### ✅ 測試 5: 離線模式 (Fallback)

**步驟：**
1. 停止後端伺服器
2. 玩遊戲並完成
3. 輸入名字

**預期結果：**
- Console 顯示錯誤: `Failed to save game to API, using localStorage fallback`
- 分數仍然被儲存（使用 localStorage）
- 排行榜仍然顯示（從 localStorage 讀取）

**驗證：**
```javascript
// 在瀏覽器 Console 執行
localStorage.getItem('tetris_duel_leaderboard')
```

---

### ✅ 測試 6: 排行榜篩選

**步驟：**
1. 玩幾場 1P 和幾場 2P
2. 檢查排行榜是否正確顯示

**預期結果：**
- 所有玩家按分數排序
- 顯示模式標籤 (1P/2P)
- 顯示日期

---

### ✅ 測試 7: 統計資訊

**驗證後端統計：**
```bash
curl http://localhost:8000/api/leaderboard/stats
```

**預期回應：**
```json
{
  "total_games": 5,
  "total_1p_games": 2,
  "total_2p_games": 3,
  "highest_score": 5000,
  "average_score": 2345.67,
  "total_lines_cleared": 150
}
```

---

## 🐛 除錯技巧

### 檢查 Console Log

前端已加入詳細的 console.log：
- `Saved Player 1 data:` - Player 1 資料已收集
- `Saved Player 2 data:` - Player 2 資料已收集
- `Submitting game:` - 準備送出 API 請求
- `Game saved successfully!` - API 請求成功
- `Failed to save game:` - API 請求失敗

### 檢查 Network Tab

1. 開啟 Chrome DevTools (F12)
2. 切換到 Network 標籤
3. 完成遊戲
4. 查看 POST 請求到 `/api/games`
5. 檢查 Request Payload 和 Response

### 檢查資料庫

```bash
mysql -u root tetris-dual

# 查看所有遊戲
SELECT * FROM games ORDER BY created_at DESC LIMIT 10;

# 查看最新一筆
SELECT * FROM games ORDER BY id DESC LIMIT 1;

# 統計
SELECT 
    mode, 
    COUNT(*) as game_count,
    AVG(player1_score) as avg_score
FROM games 
GROUP BY mode;
```

---

## 常見問題

### Q: 2P 模式只儲存了一個玩家？

A: 確認兩次 prompt 都有輸入名字。如果取消任一個，該玩家資料不會被儲存。

### Q: 排行榜沒有更新？

A: 
1. 檢查 Console 是否有錯誤
2. 確認後端正在運行
3. 檢查 `refreshScores` state 是否更新
4. 手動重新整理頁面

### Q: API 回應 422 錯誤？

A: 
- 檢查 POST 的資料格式
- 2P 模式必須包含 player2 資料
- 確認 winner 欄位為 1, 2, 或 null

### Q: CORS 錯誤？

A: 
- 確認後端 `.env` 中的 CORS_ORIGINS 包含前端 URL
- 預設應該是 `http://localhost:5173`

---

## 成功指標

✅ 1P 模式成功儲存  
✅ 2P 模式同時儲存兩個玩家  
✅ winner 欄位正確設定  
✅ 排行榜正確顯示  
✅ 統計資訊準確  
✅ 離線 fallback 正常運作  
✅ 無 Console 錯誤  
✅ Network 請求成功 (200/201)  

---

## 效能檢查

- POST 請求應該 < 100ms
- GET leaderboard 應該 < 50ms
- 頁面滾動流暢
- 無記憶體洩漏（玩多場後檢查）

