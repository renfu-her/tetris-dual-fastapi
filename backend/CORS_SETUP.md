# CORS Configuration Guide
# CORS 配置指南

## 問題說明 (Problem)

如果你看到以下錯誤，表示 CORS 配置有問題：

```
Access to fetch at 'https://tetris-game.ai-tracks.com/api/...' from origin 'https://your-frontend.com' 
has been blocked by CORS policy: No 'Access-Control-Allow-Origin' header is present on the requested resource.
```

或在後端看到 500 錯誤，但沒有詳細日誌。

## 解決方案 (Solution)

### 方法 1: 使用自動修復腳本（推薦）

在生產服務器上執行：

```bash
cd /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/backend
chmod +x fix-cors.sh
./fix-cors.sh
```

這個腳本會：
1. 備份現有的 `.env` 文件
2. 添加正確的 `CORS_ORIGINS` 配置
3. 詢問是否立即重啟服務

### 方法 2: 手動配置

#### Step 1: 編輯 .env 文件

在生產服務器上：

```bash
cd /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/backend
nano .env
```

#### Step 2: 添加或更新 CORS_ORIGINS

```env
# CORS Origins - 允許的前端來源
# 多個來源用逗號分隔，不要有空格！
CORS_ORIGINS=https://tetris-game.ai-tracks.com,http://localhost:5173,http://localhost:3000
```

**重要提示：**
- ✅ 正確：`https://tetris-game.ai-tracks.com,http://localhost:5173`
- ❌ 錯誤：`https://tetris-game.ai-tracks.com, http://localhost:5173` （有空格）
- ✅ 必須包含協議：`https://` 或 `http://`
- ❌ 不要在結尾加斜線：`https://example.com/` （錯誤）
- ✅ 正確格式：`https://example.com` （正確）

#### Step 3: 重啟服務

```bash
sudo systemctl restart tetris-dual-backend.service
```

#### Step 4: 驗證配置

```bash
# 查看日誌，確認 CORS 配置已載入
sudo journalctl -u tetris-dual-backend.service -n 20

# 應該看到類似這樣的輸出：
# >>> CORS允許的來源: ['https://tetris-game.ai-tracks.com', 'http://localhost:5173', 'http://localhost:3000']
```

## 配置說明 (Configuration Details)

### 基本配置

在 `backend/.env` 文件中：

```env
# 生產環境
CORS_ORIGINS=https://tetris-game.ai-tracks.com

# 開發 + 生產環境
CORS_ORIGINS=https://tetris-game.ai-tracks.com,http://localhost:5173,http://localhost:3000

# 允許多個域名
CORS_ORIGINS=https://tetris-game.ai-tracks.com,https://www.tetris-game.ai-tracks.com,http://localhost:5173
```

### 環境變數說明

| 環境變數 | 說明 | 預設值 | 範例 |
|---------|------|--------|------|
| `CORS_ORIGINS` | 允許的前端來源，逗號分隔 | `http://localhost:5173,http://localhost:3000` | `https://example.com,http://localhost:5173` |
| `ENV` | 環境類型 | `development` | `production` 或 `development` |

### 代碼說明

在 `backend/app/main.py` 中：

```python
# 從環境變數讀取 CORS 來源
cors_origins_env = os.getenv("CORS_ORIGINS", "http://localhost:5173,http://localhost:3000")
cors_origins = [origin.strip() for origin in cors_origins_env.split(",")]

# 開發環境自動添加 127.0.0.1
if os.getenv("ENV", "development") == "development":
    cors_origins.append("http://127.0.0.1:5173")
    cors_origins.append("http://127.0.0.1:3000")

# 顯示配置（方便調試）
print(f">>> CORS允許的來源: {cors_origins}")

# 添加 CORS 中間件
app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,        # 允許的來源
    allow_credentials=True,            # 允許憑證（cookies）
    allow_methods=["*"],               # 允許所有 HTTP 方法
    allow_headers=["*"],               # 允許所有 headers
)
```

## 測試 CORS 配置

### 在瀏覽器中測試

1. 打開前端頁面：`https://tetris-game.ai-tracks.com`
2. 打開瀏覽器開發者工具（F12）
3. 查看 Console 標籤
4. 如果有 CORS 錯誤會顯示紅色錯誤訊息

### 使用 curl 測試

```bash
# 測試預檢請求（OPTIONS）
curl -X OPTIONS https://tetris-game.ai-tracks.com/api/leaderboard \
  -H "Origin: https://tetris-game.ai-tracks.com" \
  -H "Access-Control-Request-Method: GET" \
  -v

# 應該看到：
# Access-Control-Allow-Origin: https://tetris-game.ai-tracks.com
# Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
```

### 使用 JavaScript 測試

在瀏覽器 Console 中執行：

```javascript
fetch('https://tetris-game.ai-tracks.com/api/leaderboard')
  .then(response => response.json())
  .then(data => console.log('✅ CORS 正常:', data))
  .catch(error => console.error('❌ CORS 錯誤:', error));
```

## 常見問題 (Common Issues)

### 問題 1: 仍然看到 CORS 錯誤

**可能原因：**
- 服務沒有重啟
- `.env` 文件中有空格
- 協議不匹配（http vs https）

**解決方案：**
```bash
# 確保配置正確（無空格）
cat .env | grep CORS_ORIGINS

# 重啟服務
sudo systemctl restart tetris-dual-backend.service

# 查看日誌確認配置已載入
sudo journalctl -u tetris-dual-backend.service -n 20 | grep CORS
```

### 問題 2: 配置沒有生效

**可能原因：**
- `.env` 文件位置不對
- 環境變數沒有被讀取

**解決方案：**
```bash
# 確認 .env 文件在正確位置
ls -la /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/backend/.env

# 確認文件內容
cat /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/backend/.env

# 檢查服務日誌
sudo journalctl -u tetris-dual-backend.service -n 50
```

### 問題 3: 本地開發可以，生產環境不行

**可能原因：**
- 生產環境的 `.env` 沒有包含生產域名
- Nginx 配置問題

**解決方案：**
```bash
# 確認生產環境的 CORS 配置
cat /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/backend/.env | grep CORS

# 應該包含：
# CORS_ORIGINS=https://tetris-game.ai-tracks.com,...

# 檢查 Nginx 是否攔截了 CORS headers
sudo nginx -t
sudo systemctl restart nginx
```

## 安全建議 (Security Recommendations)

### 生產環境

❌ **不建議：允許所有來源**
```python
allow_origins=["*"]  # 不安全！
```

✅ **建議：明確指定允許的來源**
```env
CORS_ORIGINS=https://tetris-game.ai-tracks.com,https://www.tetris-game.ai-tracks.com
```

### 開發環境

可以更寬鬆，但仍建議明確指定：
```env
CORS_ORIGINS=http://localhost:5173,http://localhost:3000,http://127.0.0.1:5173,http://127.0.0.1:3000
```

## 快速檢查清單

完成配置後，確認以下項目：

- [ ] `.env` 文件包含正確的 `CORS_ORIGINS`
- [ ] 域名格式正確（包含協議，無結尾斜線）
- [ ] 多個域名用逗號分隔，無空格
- [ ] 服務已重啟：`sudo systemctl restart tetris-dual-backend.service`
- [ ] 日誌顯示正確的 CORS 配置：`sudo journalctl -u tetris-dual-backend.service -n 20`
- [ ] 瀏覽器 Console 無 CORS 錯誤
- [ ] API 可以正常調用

## 相關文件

- `backend/app/main.py` - CORS 配置代碼
- `backend/.env` - 環境變數配置
- `backend/fix-cors.sh` - 自動修復腳本
- `backend/QUICK_FIX.md` - 500 錯誤修復指南

## 獲取幫助

如果仍有問題：

1. 查看日誌：`sudo journalctl -u tetris-dual-backend.service -f`
2. 執行診斷：`./diagnose-service.sh`
3. 檢查瀏覽器開發者工具的 Network 標籤
4. 查看錯誤日誌：`tail -f /var/log/uvicorn/tetris-game-error.log`

