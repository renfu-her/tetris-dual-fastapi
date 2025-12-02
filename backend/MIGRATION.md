# 資料庫遷移指南

## 快速遷移步驟

### 🚀 全新安裝（推薦）

1. **創建資料庫：**
   ```bash
   mysql -u root < create_database.sql
   ```

2. **啟動後端：**
   ```bash
   cd backend
   uv run uvicorn app.main:app --reload
   ```

3. **完成！** 資料表會自動創建。

---

### 🔄 從舊版本升級

如果你有舊的 `scores` 表資料：

#### 步驟 1: 備份資料

```bash
mysqldump -u root tetris-dual > tetris-dual-backup-$(date +%Y%m%d).sql
```

#### 步驟 2: 刪除舊資料庫並重建

```bash
mysql -u root < create_database.sql
```

#### 步驟 3: 啟動後端

```bash
cd backend
uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

看到以下訊息表示成功：
```
>>> Starting up Tetris Dual Backend...
>>> Database initialized successfully
INFO:     Application startup complete.
```

#### 步驟 4: 驗證

訪問 http://localhost:8000/docs 查看新的 API 文檔。

---

## 手動創建資料庫

如果腳本無法執行，可以手動創建：

```bash
mysql -u root
```

然後執行：

```sql
-- 刪除舊資料庫（注意：會失去所有資料！）
DROP DATABASE IF EXISTS `tetris-dual`;

-- 創建新資料庫
CREATE DATABASE `tetris-dual` 
    CHARACTER SET utf8mb4 
    COLLATE utf8mb4_unicode_ci;

-- 退出
EXIT;
```

---

## 資料遷移腳本（選用）

如果你想將舊的 `scores` 表資料轉換成新的 `games` 表格式：

**注意：** 此腳本假設舊資料中，同一時間戳的兩筆 2P 記錄是同一場遊戲。

```sql
USE `tetris-dual`;

-- 遷移 1P 記錄
INSERT INTO games (mode, player1_name, player1_score, player1_lines, winner, created_at)
SELECT 
    '1P',
    player_name,
    score,
    lines,
    NULL,
    created_at
FROM old_database.scores
WHERE mode = '1P';

-- 遷移 2P 記錄會比較複雜，因為需要配對
-- 建議手動處理或從頭開始
```

---

## 驗證遷移

### 檢查資料表

```sql
USE `tetris-dual`;
SHOW TABLES;
-- 應該看到: games
```

### 查看表結構

```sql
DESCRIBE games;
```

應該看到：
```
+---------------+-------------------+------+-----+
| Field         | Type              | Null | Key |
+---------------+-------------------+------+-----+
| id            | int               | NO   | PRI |
| mode          | enum('1P','2P')   | NO   | MUL |
| player1_name  | varchar(100)      | NO   |     |
| player1_score | int               | NO   | MUL |
| player1_lines | int               | NO   |     |
| player2_name  | varchar(100)      | YES  |     |
| player2_score | int               | YES  | MUL |
| player2_lines | int               | YES  |     |
| winner        | int               | YES  |     |
| created_at    | timestamp         | NO   |     |
+---------------+-------------------+------+-----+
```

### 測試 API

```bash
# 測試儲存遊戲
curl -X POST "http://localhost:8000/api/games" \
  -H "Content-Type: application/json" \
  -d '{
    "mode": "1P",
    "player1": {"name": "Test", "score": 1000, "lines": 10},
    "player2": null,
    "winner": null
  }'

# 查看排行榜
curl "http://localhost:8000/api/leaderboard"
```

---

## 疑難排解

### 錯誤: Unknown database 'tetris-dual'

**解決：** 執行 `mysql -u root < create_database.sql`

### 錯誤: Access denied

**解決：** 如果 MySQL 有密碼：
```bash
mysql -u root -p < create_database.sql
```

並更新 `.env`:
```
DATABASE_URL=mysql+pymysql://root:YOUR_PASSWORD@localhost/tetris-dual
```

### 錯誤: Table 'games' doesn't exist

**解決：** 確保後端已啟動，SQLAlchemy 會自動創建表。

### 警告: Can't drop database (doesn't exist)

**解決：** 這是正常的，表示是第一次安裝。

---

## 回滾到舊版本

如果需要回到舊版本：

1. 還原備份：
   ```bash
   mysql -u root < tetris-dual-backup-YYYYMMDD.sql
   ```

2. 切換到舊版本的程式碼

3. 重啟後端

---

## 需要協助？

查看以下文檔：
- [README.md](README.md) - 基本說明
- [SETUP.md](SETUP.md) - 詳細設定
- [API_CHANGES.md](API_CHANGES.md) - API 變更說明
- [QUICKSTART.md](QUICKSTART.md) - 快速開始
