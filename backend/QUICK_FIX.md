# 🚨 Quick Fix for 500 Error
# 快速修復 500 錯誤

## 問題診斷 (Problem Diagnosis)

你看到 `500 Internal Server Error` 表示後端服務有問題。

## 🔍 Step 1: 檢查服務狀態 (Check Service Status)

在服務器上執行：

```bash
# 檢查服務是否在運行
sudo systemctl status tetris-dual-backend.service

# 如果顯示 "inactive (dead)" 或 "failed"，表示服務沒有運行
```

## 🛠️ Step 2: 常見問題快速修復

### 問題 A: 服務未啟動

```bash
# 啟動服務
sudo systemctl start tetris-dual-backend.service

# 檢查狀態
sudo systemctl status tetris-dual-backend.service

# 設置開機自動啟動
sudo systemctl enable tetris-dual-backend.service
```

### 問題 B: 服務啟動失敗

```bash
# 查看詳細錯誤
sudo journalctl -u tetris-dual-backend.service -n 50 --no-pager

# 查看錯誤日誌
tail -n 50 /var/log/uvicorn/tetris-game-error.log
```

### 問題 C: 數據庫連接失敗

```bash
# 檢查 MySQL 是否運行
sudo systemctl status mysql

# 如果 MySQL 沒運行，啟動它
sudo systemctl start mysql

# 測試數據庫連接
mysql -u root -p tetris-dual -e "SELECT 1;"
```

### 問題 D: 依賴未安裝

```bash
# 進入後端目錄
cd /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/backend

# 安裝依賴
uv sync

# 重啟服務
sudo systemctl restart tetris-dual-backend.service
```

### 問題 E: 日誌目錄權限問題

```bash
# 創建日誌目錄（如果不存在）
sudo mkdir -p /var/log/uvicorn

# 設置正確的權限
sudo chown -R ai-tracks-tetris-game:ai-tracks-tetris-game /var/log/uvicorn
sudo chmod 755 /var/log/uvicorn

# 重啟服務
sudo systemctl restart tetris-dual-backend.service
```

## 🔧 Step 3: 完整診斷

使用我們的診斷腳本：

```bash
cd /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/backend

# 給腳本執行權限
chmod +x diagnose-service.sh

# 運行診斷
./diagnose-service.sh
```

## 📊 Step 4: 檢查端口是否監聽

```bash
# 檢查 8098 端口是否有進程在監聽
sudo netstat -tlnp | grep 8098

# 或使用 ss
sudo ss -tlnp | grep 8098

# 應該看到類似這樣的輸出：
# tcp  0  0 127.0.0.1:8098  0.0.0.0:*  LISTEN  12345/gunicorn
```

## 🌐 Step 5: 檢查 Nginx 配置

```bash
# 檢查 Nginx 配置
sudo nginx -t

# 查看相關配置
sudo cat /etc/nginx/sites-enabled/tetris-game.ai-tracks.com

# 重啟 Nginx
sudo systemctl restart nginx
```

## 🔄 Step 6: 完全重啟流程

如果上述都不行，執行完全重啟：

```bash
# 1. 停止服務
sudo systemctl stop tetris-dual-backend.service

# 2. 確認沒有殘留進程
sudo pkill -f gunicorn

# 3. 重新同步依賴
cd /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/backend
uv sync

# 4. 檢查環境變數
cat .env

# 5. 重新載入 systemd
sudo systemctl daemon-reload

# 6. 啟動服務
sudo systemctl start tetris-dual-backend.service

# 7. 查看實時日誌
sudo journalctl -u tetris-dual-backend.service -f
```

## 📝 Step 7: 查看詳細日誌

```bash
# 查看訪問日誌
tail -f /var/log/uvicorn/tetris-game-access.log

# 查看錯誤日誌
tail -f /var/log/uvicorn/tetris-game-error.log

# 查看 systemd 日誌
sudo journalctl -u tetris-dual-backend.service -f
```

## ✅ Step 8: 驗證修復

```bash
# 測試本地端點
curl http://127.0.0.1:8098/

# 應該返回：
# {"status":"online","message":"Tetris Dual Backend API","version":"1.0.0","docs":"/docs"}

# 測試健康檢查
curl http://127.0.0.1:8098/health

# 測試外部訪問
curl https://tetris-game.ai-tracks.com/api/

# 或在瀏覽器訪問
# https://tetris-game.ai-tracks.com/docs
```

## 🐛 常見錯誤碼

### ImportError / ModuleNotFoundError
```bash
# 重新安裝依賴
cd backend
uv sync
sudo systemctl restart tetris-dual-backend.service
```

### MySQL Connection Error
```bash
# 檢查 .env 中的數據庫設置
cat .env | grep DB_

# 確認 MySQL 運行中
sudo systemctl status mysql

# 測試連接
mysql -u root -p -e "SHOW DATABASES;"
```

### Permission Denied
```bash
# 修復權限
sudo chown -R ai-tracks-tetris-game:ai-tracks-tetris-game /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/backend
sudo chown -R ai-tracks-tetris-game:ai-tracks-tetris-game /var/log/uvicorn
```

### Port Already in Use
```bash
# 查找佔用端口的進程
sudo lsof -i :8098

# 殺死該進程
sudo kill -9 <PID>

# 重啟服務
sudo systemctl restart tetris-dual-backend.service
```

## 📞 如果還是不行

1. **收集完整錯誤資訊**：
   ```bash
   # 導出所有相關日誌
   sudo journalctl -u tetris-dual-backend.service -n 100 > ~/backend-systemd.log
   tail -n 100 /var/log/uvicorn/tetris-game-error.log > ~/backend-error.log
   ./diagnose-service.sh > ~/backend-diagnosis.log
   ```

2. **檢查這些文件**：
   - `~/backend-systemd.log`
   - `~/backend-error.log`
   - `~/backend-diagnosis.log`

3. **常見的最終解決方案**：
   ```bash
   # 完全重建虛擬環境
   cd /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/backend
   rm -rf .venv uv.lock
   uv sync
   sudo systemctl restart tetris-dual-backend.service
   ```

## 🎯 快速檢查清單

- [ ] MySQL 運行中？`sudo systemctl status mysql`
- [ ] 服務運行中？`sudo systemctl status tetris-dual-backend.service`
- [ ] 端口監聽中？`sudo netstat -tlnp | grep 8098`
- [ ] 依賴已安裝？`uv run python -c "import fastapi"`
- [ ] 日誌目錄權限正確？`ls -la /var/log/uvicorn`
- [ ] 本地測試成功？`curl http://127.0.0.1:8098/`
- [ ] Nginx 配置正確？`sudo nginx -t`

---

**最快速的診斷方式：**

```bash
# 在服務器上執行這一行
cd /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/backend && ./diagnose-service.sh
```

這會顯示所有問題和建議的修復方法！

