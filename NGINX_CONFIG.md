# Nginx Configuration for Tetris Dual
# Nginx 配置指南

## 完整的 Nginx 配置示例

這是一個完整的 Nginx 配置，用於 Tetris Dual 遊戲，包含前端靜態文件服務和後端 API 反向代理。

### 配置文件位置

```
/etc/nginx/sites-available/tetris-game.ai-tracks.com
```

### 完整配置

```nginx
# Tetris Dual Game - Nginx Configuration
# Domain: tetris-game.ai-tracks.com

# HTTP -> HTTPS 重定向
server {
    listen 80;
    listen [::]:80;
    server_name tetris-game.ai-tracks.com www.tetris-game.ai-tracks.com;
    
    # 重定向到 HTTPS
    return 301 https://$server_name$request_uri;
}

# HTTPS Server
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name tetris-game.ai-tracks.com www.tetris-game.ai-tracks.com;

    # SSL 證書配置（根據你的 SSL 提供商調整）
    ssl_certificate /path/to/ssl/fullchain.pem;
    ssl_certificate_key /path/to/ssl/privkey.pem;
    
    # SSL 安全配置
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # 根目錄 - 前端靜態文件
    root /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/frontend/dist;
    index index.html;

    # 日誌配置
    access_log /var/log/nginx/tetris-game-access.log;
    error_log /var/log/nginx/tetris-game-error.log;

    # Gzip 壓縮
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript 
               application/x-javascript application/xml+rss 
               application/javascript application/json;

    # 靜態資源緩存
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|woff|woff2|ttf|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        try_files $uri =404;
    }

    # API 反向代理
    location /api/ {
        # 後端 FastAPI 服務運行在 127.0.0.1:8098
        proxy_pass http://127.0.0.1:8098/api/;
        
        # 代理頭部設置
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # 超時設置
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        
        # 緩衝設置
        proxy_buffering on;
        proxy_buffer_size 4k;
        proxy_buffers 8 4k;
        
        # CORS 頭部（如果後端沒有設置）
        # add_header 'Access-Control-Allow-Origin' 'https://tetris-game.ai-tracks.com' always;
        # add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS' always;
        # add_header 'Access-Control-Allow-Headers' 'Content-Type' always;
    }

    # API 文檔代理（可選）
    location /docs {
        proxy_pass http://127.0.0.1:8098/docs;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /redoc {
        proxy_pass http://127.0.0.1:8098/redoc;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /openapi.json {
        proxy_pass http://127.0.0.1:8098/openapi.json;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # 健康檢查端點
    location /health {
        proxy_pass http://127.0.0.1:8098/health;
        proxy_set_header Host $host;
        access_log off;
    }

    # 根路徑也代理到後端（顯示 API 資訊）
    location = / {
        # 優先嘗試靜態文件（前端）
        try_files /index.html =404;
    }

    # SPA 路由支援 - 所有其他路徑返回 index.html
    location / {
        try_files $uri $uri/ /index.html;
    }

    # 安全頭部
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
}
```

## 部署步驟

### 1. 創建配置文件

```bash
sudo nano /etc/nginx/sites-available/tetris-game.ai-tracks.com
```

將上面的配置貼上，並根據你的實際情況修改：
- SSL 證書路徑
- 網站根目錄路徑
- 後端端口（如果不是 8098）

### 2. 啟用站點

```bash
# 創建符號連結
sudo ln -s /etc/nginx/sites-available/tetris-game.ai-tracks.com /etc/nginx/sites-enabled/

# 測試配置
sudo nginx -t

# 如果測試通過，重新載入 Nginx
sudo systemctl reload nginx
```

### 3. 設置正確的文件權限

```bash
# 確保 Nginx 可以讀取文件
sudo chown -R www-data:www-data /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/frontend/dist/
sudo chmod -R 755 /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/frontend/dist/
```

### 4. 創建日誌目錄

```bash
sudo mkdir -p /var/log/nginx
sudo chown -R www-data:www-data /var/log/nginx
```

## 驗證配置

### 檢查 Nginx 語法

```bash
sudo nginx -t
```

### 重新載入配置

```bash
sudo systemctl reload nginx
```

### 查看日誌

```bash
# 訪問日誌
sudo tail -f /var/log/nginx/tetris-game-access.log

# 錯誤日誌
sudo tail -f /var/log/nginx/tetris-game-error.log
```

## 測試

### 測試靜態文件

```bash
# 測試首頁
curl -I https://tetris-game.ai-tracks.com/

# 測試 CSS 文件
curl -I https://tetris-game.ai-tracks.com/assets/index-*.css

# 測試 JS 文件
curl -I https://tetris-game.ai-tracks.com/assets/index-*.js
```

### 測試 API 代理

```bash
# 測試 API 根路徑
curl https://tetris-game.ai-tracks.com/api/

# 測試健康檢查
curl https://tetris-game.ai-tracks.com/health

# 測試排行榜
curl https://tetris-game.ai-tracks.com/api/leaderboard
```

## 常見問題

### 問題 1: 404 Not Found for CSS/JS files

**原因：** 構建文件沒有正確部署

**解決：**
```bash
# 檢查文件是否存在
ls -la /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/frontend/dist/

# 檢查 assets 目錄
ls -la /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/frontend/dist/assets/

# 確保 index.html 存在
cat /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/frontend/dist/index.html
```

### 問題 2: 502 Bad Gateway for /api/

**原因：** 後端服務沒有運行

**解決：**
```bash
# 檢查後端服務
sudo systemctl status tetris-dual-backend.service

# 檢查端口
sudo netstat -tlnp | grep 8098

# 啟動服務
sudo systemctl start tetris-dual-backend.service
```

### 問題 3: CORS 錯誤

**原因：** 後端 CORS 配置不正確

**解決：**
```bash
# 檢查後端 CORS 配置
cd /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/backend
cat .env | grep CORS

# 應該包含：
# CORS_ORIGINS=https://tetris-game.ai-tracks.com,...

# 重啟後端
sudo systemctl restart tetris-dual-backend.service
```

### 問題 4: 文件權限錯誤

**解決：**
```bash
# 修復權限
sudo chown -R www-data:www-data /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/frontend/dist/
sudo chmod -R 755 /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/frontend/dist/
```

## 性能優化

### 啟用 HTTP/2

已在配置中啟用：
```nginx
listen 443 ssl http2;
```

### 啟用 Gzip 壓縮

已在配置中啟用，可以調整壓縮級別：
```nginx
gzip_comp_level 6;
```

### 設置瀏覽器緩存

已為靜態資源設置 1 年緩存：
```nginx
expires 1y;
```

### 啟用 FastCGI 緩存（可選）

```nginx
# 在 http 塊中
fastcgi_cache_path /var/cache/nginx levels=1:2 keys_zone=api_cache:10m max_size=100m inactive=60m;

# 在 location /api/ 中
fastcgi_cache api_cache;
fastcgi_cache_valid 200 60m;
```

## 安全加固

### 限制請求速率

```nginx
# 在 http 塊中
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;

# 在 location /api/ 中
limit_req zone=api_limit burst=20 nodelay;
```

### 禁止訪問隱藏文件

```nginx
location ~ /\. {
    deny all;
    access_log off;
    log_not_found off;
}
```

### 添加安全頭部

已在配置中包含基本安全頭部。

## 監控

### 啟用 Nginx 狀態頁面

```nginx
location /nginx_status {
    stub_status on;
    access_log off;
    allow 127.0.0.1;
    deny all;
}
```

### 查看狀態

```bash
curl http://127.0.0.1/nginx_status
```

## 相關命令

```bash
# 檢查配置
sudo nginx -t

# 重新載入配置
sudo systemctl reload nginx

# 重啟 Nginx
sudo systemctl restart nginx

# 查看狀態
sudo systemctl status nginx

# 查看錯誤日誌
sudo tail -f /var/log/nginx/error.log

# 查看訪問日誌
sudo tail -f /var/log/nginx/tetris-game-access.log
```

