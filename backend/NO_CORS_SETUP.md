# 無需 CORS 的設置指南
# No CORS Setup Guide

## 🎯 為什麼不需要 CORS？

當前端和後端通過 **同一個域名** 訪問時，瀏覽器認為它們是 **同源** 的，就不會有 CORS 問題！

## 📐 架構設計

```
瀏覽器請求：
  ├─ https://tetris-game.ai-tracks.com/          → Nginx → 前端靜態文件
  └─ https://tetris-game.ai-tracks.com/api/      → Nginx → 後端 FastAPI (127.0.0.1:8098)
```

**關鍵點：**
- 前端和後端都使用 `https://tetris-game.ai-tracks.com`
- 後端 API 路徑以 `/api/` 開頭
- Nginx 作為反向代理
- 瀏覽器認為這是同源請求，不會觸發 CORS 檢查

## ✅ 完整設置步驟

### Step 1: Nginx 配置

創建或更新 `/etc/nginx/sites-available/tetris-game.ai-tracks.com`：

```nginx
server {
    listen 443 ssl http2;
    server_name tetris-game.ai-tracks.com;

    # SSL 配置
    ssl_certificate /path/to/ssl/fullchain.pem;
    ssl_certificate_key /path/to/ssl/privkey.pem;

    # 前端靜態文件
    root /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/frontend/dist;
    index index.html;

    # 日誌
    access_log /var/log/nginx/tetris-game-access.log;
    error_log /var/log/nginx/tetris-game-error.log;

    # API 反向代理 - 這是關鍵！
    location /api/ {
        # 代理到後端
        proxy_pass http://127.0.0.1:8098/api/;
        
        # 必要的代理頭部
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # 超時設置
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # 健康檢查（可選）
    location /health {
        proxy_pass http://127.0.0.1:8098/health;
        proxy_set_header Host $host;
        access_log off;
    }

    # API 文檔（可選）
    location /docs {
        proxy_pass http://127.0.0.1:8098/docs;
        proxy_set_header Host $host;
    }

    location /redoc {
        proxy_pass http://127.0.0.1:8098/redoc;
        proxy_set_header Host $host;
    }

    location /openapi.json {
        proxy_pass http://127.0.0.1:8098/openapi.json;
        proxy_set_header Host $host;
    }

    # 靜態資源緩存
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|woff|woff2|ttf|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # SPA 路由支援
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

### Step 2: 更新前端 API URL

在 `frontend/.env` 中：

```env
# 使用相對路徑，這樣就是同源請求
VITE_API_BASE_URL=/api

# 或使用完整 URL（但必須是同一個域名）
# VITE_API_BASE_URL=https://tetris-game.ai-tracks.com/api
```

### Step 3: 更新 Frontend Service

檢查 `frontend/services/leaderboardService.ts`：

```typescript
// 應該使用環境變數的 API URL
const API_BASE_URL = (import.meta as any).env?.VITE_API_BASE_URL || '/api';
```

### Step 4: 後端配置

在 `backend/.env` 中設置生產環境：

```env
ENV=production
```

這樣後端就不會啟用 CORS 中間件。

### Step 5: 重新構建和部署

#### 後端

```bash
# 在服務器上
cd /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/backend

# 更新 .env
echo "ENV=production" >> .env

# 重啟服務
sudo systemctl restart tetris-dual-backend.service
```

#### 前端

```bash
# 在本地
cd frontend

# 更新 .env
echo "VITE_API_BASE_URL=/api" > .env

# 重新構建
pnpm build

# 部署到服務器
rsync -avz --delete dist/ user@server:/home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/frontend/dist/
```

#### Nginx

```bash
# 在服務器上
sudo nginx -t
sudo systemctl reload nginx
```

## 🔍 驗證設置

### 測試 API 訪問

```bash
# 測試前端
curl https://tetris-game.ai-tracks.com/

# 測試 API（注意路徑以 /api/ 開頭）
curl https://tetris-game.ai-tracks.com/api/

# 測試健康檢查
curl https://tetris-game.ai-tracks.com/health

# 測試排行榜
curl https://tetris-game.ai-tracks.com/api/leaderboard
```

### 在瀏覽器中驗證

1. 訪問 https://tetris-game.ai-tracks.com
2. 打開開發者工具（F12）
3. 查看 Network 標籤
4. API 請求應該顯示：
   - URL: `https://tetris-game.ai-tracks.com/api/...`
   - Status: `200 OK`
   - **沒有 CORS 相關的警告或錯誤**

## 🎨 架構優勢

### ✅ 優點

1. **無需 CORS**：前後端同源，瀏覽器不會觸發 CORS 檢查
2. **更安全**：不需要配置 `Access-Control-Allow-Origin`
3. **更簡單**：減少配置複雜度
4. **更快**：減少預檢請求（OPTIONS）
5. **統一域名**：所有流量都通過一個域名
6. **SSL 統一管理**：只需要一個 SSL 證書

### ⚠️ 注意事項

1. **開發環境仍需 CORS**：本地開發時前後端運行在不同端口
2. **Nginx 必須正確配置**：確保反向代理設置正確
3. **路徑必須匹配**：前端 API 路徑要以 `/api/` 開頭

## 🔧 開發環境配置

開發環境下，前端和後端運行在不同端口，仍需要 CORS：

### 後端 `.env`

```env
ENV=development
```

### 前端 `.env`

```env
# 開發環境指向本地後端
VITE_API_BASE_URL=http://localhost:8000/api
```

### 後端會自動啟用 CORS

當 `ENV=development` 時，後端會自動啟用 CORS 中間件。

## 📊 對比：有 CORS vs 無 CORS

### 傳統方式（需要 CORS）

```
前端: https://frontend.example.com
後端: https://api.example.com

❌ 跨域請求，需要 CORS
❌ 需要配置 Access-Control-Allow-Origin
❌ 預檢請求增加延遲
```

### 反向代理方式（無需 CORS）

```
前端: https://example.com/
後端: https://example.com/api/

✅ 同源請求，不需要 CORS
✅ 不需要額外配置
✅ 沒有預檢請求
```

## 🚀 生產環境檢查清單

部署前確認：

- [ ] Nginx 配置包含 `/api/` 反向代理
- [ ] 後端 `ENV=production`
- [ ] 前端 `VITE_API_BASE_URL=/api`
- [ ] Nginx 配置測試通過：`sudo nginx -t`
- [ ] 後端服務運行中
- [ ] SSL 證書有效
- [ ] 前端構建文件已部署
- [ ] 瀏覽器測試無 CORS 錯誤

## 🆘 故障排除

### 問題：API 請求返回 404

**原因：** Nginx 反向代理配置不正確

**解決：**
```bash
# 檢查 Nginx 配置
sudo nginx -t

# 查看 Nginx 錯誤日誌
sudo tail -f /var/log/nginx/error.log

# 確認 location /api/ 配置存在
sudo cat /etc/nginx/sites-enabled/tetris-game.ai-tracks.com | grep -A 10 "location /api/"
```

### 問題：API 請求返回 502 Bad Gateway

**原因：** 後端服務沒有運行

**解決：**
```bash
# 檢查後端服務
sudo systemctl status tetris-dual-backend.service

# 檢查端口監聽
sudo netstat -tlnp | grep 8098

# 啟動服務
sudo systemctl start tetris-dual-backend.service
```

### 問題：仍然出現 CORS 錯誤

**原因：** 前端 API URL 配置錯誤，沒有使用相對路徑

**解決：**
```bash
# 檢查前端配置
cat frontend/.env

# 應該是：
# VITE_API_BASE_URL=/api
# 而不是：
# VITE_API_BASE_URL=https://different-domain.com/api

# 重新構建
cd frontend
pnpm build
```

## 📚 相關文件

- `backend/app/main.py` - CORS 配置邏輯
- `frontend/.env` - 前端環境變數
- `/etc/nginx/sites-available/tetris-game.ai-tracks.com` - Nginx 配置
- `NGINX_CONFIG.md` - 完整 Nginx 配置指南

## 💡 最佳實踐

1. **生產環境**：使用 Nginx 反向代理，不需要 CORS
2. **開發環境**：啟用 CORS 以支援本地開發
3. **統一域名**：前後端使用同一個域名
4. **路徑規範**：API 路徑統一以 `/api/` 開頭
5. **環境變數**：使用環境變數區分開發和生產環境

---

**總結：** 使用 Nginx 反向代理是最佳方案，既安全又簡單，完全不需要處理 CORS 問題！

