# 🚨 Production Fix Checklist
# 生產環境修復檢查清單

根據你的截圖，有兩個主要問題：
1. ❌ **404 Not Found** - `index.css` 和其他靜態文件找不到
2. ❌ **API Offline** - 後端無法連接

## 📋 快速修復步驟

### ✅ Step 1: 修復後端服務（優先）

在**生產服務器**上執行：

```bash
# 1.1 檢查服務狀態
sudo systemctl status tetris-dual-backend.service

# 1.2 如果服務沒運行或失敗，啟動它
sudo systemctl start tetris-dual-backend.service

# 1.3 如果啟動失敗，查看日誌
sudo journalctl -u tetris-dual-backend.service -n 50

# 1.4 檢查端口監聽
sudo netstat -tlnp | grep 8098
# 或
sudo ss -tlnp | grep 8098

# 1.5 測試本地 API
curl http://127.0.0.1:8098/
# 應該返回 JSON 而不是錯誤
```

**如果服務無法啟動，可能的問題：**

```bash
# 問題 A: 依賴未安裝
cd /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/backend
uv sync
sudo systemctl restart tetris-dual-backend.service

# 問題 B: 數據庫連接失敗
sudo systemctl status mysql
sudo systemctl start mysql

# 問題 C: 日誌目錄權限
sudo mkdir -p /var/log/uvicorn
sudo chown -R ai-tracks-tetris-game:ai-tracks-tetris-game /var/log/uvicorn

# 問題 D: CORS 配置
cat /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/backend/.env
# 確保包含：CORS_ORIGINS=https://tetris-game.ai-tracks.com,...
```

### ✅ Step 2: 修復前端靜態文件

#### 2A. 在本地構建前端

```bash
# 在你的本地電腦上
cd d:\python\tetris-dual\frontend

# 確保環境變數正確
# 編輯 .env 文件，設置：
# VITE_API_BASE_URL=https://tetris-game.ai-tracks.com/api

# 運行部署腳本
chmod +x deploy.sh
./deploy.sh

# 或手動執行：
pnpm install
pnpm build
```

#### 2B. 部署到生產服務器

方法 1：使用 rsync（推薦）

```bash
# 從本地上傳到服務器
rsync -avz --delete dist/ your-user@your-server:/home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/frontend/dist/

# 或者如果有 SSH key：
rsync -avz --delete -e "ssh -i ~/.ssh/your-key.pem" dist/ user@server:/path/to/dist/
```

方法 2：使用 SCP

```bash
scp -r dist/* your-user@your-server:/home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/frontend/dist/
```

方法 3：在服務器上直接構建

```bash
# SSH 到服務器
ssh your-user@your-server

# 進入前端目錄
cd /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/frontend

# 確保 .env 配置正確
cat .env
# 應該包含：VITE_API_BASE_URL=https://tetris-game.ai-tracks.com/api

# 構建
pnpm install
pnpm build
```

#### 2C. 修復文件權限

在**生產服務器**上：

```bash
# 設置正確的所有者
sudo chown -R www-data:www-data /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/frontend/dist/

# 設置正確的權限
sudo chmod -R 755 /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/frontend/dist/

# 確認文件存在
ls -la /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/frontend/dist/
ls -la /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/frontend/dist/assets/
```

### ✅ Step 3: 檢查 Nginx 配置

在**生產服務器**上：

```bash
# 3.1 檢查 Nginx 配置語法
sudo nginx -t

# 3.2 查看站點配置
sudo cat /etc/nginx/sites-enabled/tetris-game.ai-tracks.com

# 3.3 確認根目錄配置正確
# 應該包含：
# root /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/frontend/dist;

# 3.4 重新載入 Nginx
sudo systemctl reload nginx

# 3.5 查看 Nginx 錯誤日誌
sudo tail -f /var/log/nginx/error.log
```

**參考完整 Nginx 配置：**
查看 `NGINX_CONFIG.md` 文件中的完整配置示例。

### ✅ Step 4: 驗證修復

#### 4.1 測試後端

```bash
# 在服務器上測試
curl http://127.0.0.1:8098/
curl http://127.0.0.1:8098/health
curl http://127.0.0.1:8098/api/leaderboard

# 從外部測試
curl https://tetris-game.ai-tracks.com/api/
curl https://tetris-game.ai-tracks.com/health
```

#### 4.2 測試前端

```bash
# 測試首頁
curl -I https://tetris-game.ai-tracks.com/

# 測試靜態文件
curl -I https://tetris-game.ai-tracks.com/assets/index-*.css
```

#### 4.3 在瀏覽器測試

1. 清除瀏覽器緩存（Ctrl+Shift+Delete）
2. 訪問 https://tetris-game.ai-tracks.com
3. 打開開發者工具（F12）
4. 檢查：
   - ✅ 沒有 404 錯誤
   - ✅ 右上角顯示 "✓ API Online"（綠色）
   - ✅ Network 標籤中所有請求都是 200 OK

## 🔍 診斷工具

### 快速檢查所有狀態

```bash
cd /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/backend
./check-production.sh
```

### 詳細診斷

```bash
cd /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/backend
./diagnose-service.sh
```

## 📊 檢查清單

在修復後，確認以下所有項目：

### 後端檢查
- [ ] MySQL 運行中：`sudo systemctl status mysql`
- [ ] 後端服務運行中：`sudo systemctl status tetris-dual-backend.service`
- [ ] 端口 8098 監聽中：`sudo netstat -tlnp | grep 8098`
- [ ] 本地 API 響應正常：`curl http://127.0.0.1:8098/`
- [ ] CORS 配置包含生產域名
- [ ] 日誌目錄權限正確

### 前端檢查
- [ ] dist 目錄存在且有文件
- [ ] index.html 存在
- [ ] assets 目錄有 CSS 和 JS 文件
- [ ] .env 包含正確的 VITE_API_BASE_URL
- [ ] 文件權限正確（755, www-data）
- [ ] Nginx 根目錄指向正確路徑

### Nginx 檢查
- [ ] Nginx 配置語法正確：`sudo nginx -t`
- [ ] Nginx 運行中：`sudo systemctl status nginx`
- [ ] 靜態文件路徑正確
- [ ] API 反向代理配置正確
- [ ] SSL 證書有效

### 整體檢查
- [ ] 外部 API 訪問正常：`curl https://tetris-game.ai-tracks.com/api/`
- [ ] 外部首頁訪問正常：`curl https://tetris-game.ai-tracks.com/`
- [ ] 瀏覽器中沒有 404 錯誤
- [ ] 瀏覽器中沒有 CORS 錯誤
- [ ] API 狀態顯示 "Online"（綠色）

## 🆘 如果還是不行

### 收集診斷信息

```bash
# 後端日誌
sudo journalctl -u tetris-dual-backend.service -n 100 > backend-systemd.log
tail -n 100 /var/log/uvicorn/tetris-game-error.log > backend-error.log

# Nginx 日誌
sudo tail -n 100 /var/log/nginx/error.log > nginx-error.log
sudo tail -n 100 /var/log/nginx/tetris-game-error.log > nginx-tetris-error.log

# 診斷報告
cd /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/backend
./diagnose-service.sh > diagnosis.log
./check-production.sh > production-check.log
```

### 查看這些日誌文件找出問題

### 最後手段：完全重啟

```bash
# 1. 停止所有服務
sudo systemctl stop tetris-dual-backend.service
sudo systemctl stop nginx

# 2. 清理可能的殘留進程
sudo pkill -f gunicorn
sudo pkill -f uvicorn

# 3. 重新同步後端依賴
cd /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/backend
uv sync

# 4. 檢查配置
cat .env
# 確保 CORS_ORIGINS 正確

# 5. 重新載入 systemd
sudo systemctl daemon-reload

# 6. 啟動服務
sudo systemctl start mysql
sudo systemctl start tetris-dual-backend.service
sudo systemctl start nginx

# 7. 檢查狀態
sudo systemctl status tetris-dual-backend.service
sudo systemctl status nginx

# 8. 查看實時日誌
sudo journalctl -u tetris-dual-backend.service -f
```

## 📞 聯繫支援

如果完成以上所有步驟後仍有問題，請提供：
1. `./check-production.sh` 的輸出
2. `./diagnose-service.sh` 的輸出
3. 瀏覽器開發者工具的 Console 和 Network 截圖
4. `/var/log/uvicorn/tetris-game-error.log` 的最後 50 行
5. `/var/log/nginx/error.log` 的最後 50 行

