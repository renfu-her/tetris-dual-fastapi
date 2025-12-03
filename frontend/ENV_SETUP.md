# Environment Variables Setup
# 環境變數設定指南

## Quick Start / 快速開始

1. **Create `.env` file / 創建 `.env` 文件：**
   ```bash
   cd frontend
   cp env.template .env
   ```

2. **Edit the `.env` file / 編輯 `.env` 文件：**
   
   For production / 生產環境：
   ```env
   VITE_API_BASE_URL=https://tetris-game.ai-tracks.com/api
   ```
   
   For local development / 本地開發：
   ```env
   VITE_API_BASE_URL=http://localhost:8000/api
   ```

3. **Start the development server / 啟動開發服務器：**
   ```bash
   pnpm dev
   # or
   npm run dev
   ```

## Environment Variables / 環境變數

### `VITE_API_BASE_URL`
- **Required / 必需：** Yes
- **Description / 說明：** Backend API base URL / 後端 API 基礎網址
- **Production / 生產環境：** `https://tetris-game.ai-tracks.com/api`
- **Development / 開發環境：** `http://localhost:8000/api`
- **Default / 預設值：** `http://localhost:8000/api`

### `GEMINI_API_KEY`
- **Required / 必需：** No (optional / 選用)
- **Description / 說明：** Google Gemini API key for AI features / Google Gemini API 金鑰，用於 AI 功能
- **Note / 注意：** Currently using local AI simulation, this is not required / 目前使用本地 AI 模擬，不需要此設定

## Files / 相關文件

- `env.template` - Environment variables template / 環境變數模板
- `.env` - Your local configuration (not committed to git) / 你的本地配置（不會提交到 git）
- `.env.local` - Alternative local configuration file / 替代的本地配置文件
- `vite-env.d.ts` - TypeScript type definitions for environment variables / 環境變數的 TypeScript 類型定義

## Troubleshooting / 疑難排解

### Changes not taking effect / 更改沒有生效
- Restart the development server / 重啟開發服務器
- Clear browser cache / 清除瀏覽器快取
- Make sure the variable name starts with `VITE_` / 確保變數名稱以 `VITE_` 開頭

### API connection failed / API 連接失敗
- Check if the backend is running / 檢查後端是否正在運行
- Verify the `VITE_API_BASE_URL` is correct / 驗證 `VITE_API_BASE_URL` 是否正確
- Check CORS settings in backend / 檢查後端的 CORS 設定

## More Information / 更多資訊

- [Vite Environment Variables Documentation](https://vitejs.dev/guide/env-and-mode.html)
- See `frontend/README.md` for general setup instructions / 查看 `frontend/README.md` 了解一般設定說明

