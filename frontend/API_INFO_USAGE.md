# API Info Component Usage
# API 資訊組件使用說明

## Overview / 概述

The API Info component is a React modal that displays comprehensive information about the backend API connection, status, and available endpoints.

API 資訊組件是一個 React 彈窗，顯示後端 API 的連接、狀態和可用端點的完整資訊。

## Features / 功能

### 1. Real-time API Status Check / 即時 API 狀態檢查
- Automatically fetches API status when opened / 打開時自動獲取 API 狀態
- Shows connection status (online/offline) / 顯示連接狀態（線上/離線）
- Displays API version information / 顯示 API 版本資訊
- Health check indicator / 健康檢查指示器

### 2. Connection Information / 連接資訊
- Current API Base URL / 當前 API 基礎網址
- API Root URL / API 根網址
- Loaded from environment variables / 從環境變數載入

### 3. Available Endpoints / 可用端點
Lists all API endpoints with their HTTP methods:
列出所有 API 端點及其 HTTP 方法：

- `GET /` - API information / API 資訊
- `GET /health` - Health check / 健康檢查
- `POST /api/games` - Save game record / 儲存遊戲記錄
- `GET /api/leaderboard` - Leaderboard / 排行榜
- `GET /api/leaderboard/stats` - Statistics / 統計資訊

### 4. Documentation Links / 文檔連結
- Swagger UI - Interactive API documentation / 互動式 API 文檔
- ReDoc - Alternative API documentation / 替代 API 文檔

### 5. Environment Configuration / 環境配置
- Shows current environment setup / 顯示當前環境設定
- Instructions for modifying API URL / 修改 API URL 的說明

### 6. Error Handling / 錯誤處理
- Clear error messages when connection fails / 連接失敗時的清晰錯誤訊息
- Helpful hints for troubleshooting / 有用的疑難排解提示
- Backend startup command suggestions / 後端啟動命令建議

## How to Use / 如何使用

### Opening the Modal / 打開彈窗

1. From the main menu, click the "🔌 API Info" button
   從主選單點擊 "🔌 API Info" 按鈕

2. The modal will automatically:
   彈窗會自動：
   - Fetch API status / 獲取 API 狀態
   - Check health endpoint / 檢查健康端點
   - Display all information / 顯示所有資訊

### Viewing Information / 查看資訊

The modal displays several sections:
彈窗顯示多個部分：

#### API Status / API 狀態
- Green indicators for healthy status / 健康狀態的綠色指示器
- Version number / 版本號
- Service name / 服務名稱

#### Connection Info / 連接資訊
- API URLs in monospace font / 等寬字體顯示的 API URL
- Easy to copy and paste / 易於複製貼上

#### Endpoints List / 端點列表
- Color-coded HTTP methods / 顏色標記的 HTTP 方法
  - Green: GET methods / 綠色：GET 方法
  - Blue: POST methods / 藍色：POST 方法
- Endpoint paths / 端點路徑
- Brief description / 簡短描述

#### Documentation Links / 文檔連結
- Click to open in new tab / 點擊在新分頁中打開
- External link indicators / 外部連結指示器

### Closing the Modal / 關閉彈窗

- Click the "✕" button in the top-right corner / 點擊右上角的 "✕" 按鈕
- Click the "關閉" (Close) button at the bottom / 點擊底部的 "關閉" 按鈕
- Click outside the modal (on the overlay) / 點擊彈窗外部（覆蓋層上）

## Troubleshooting / 疑難排解

### Connection Failed / 連接失敗

If you see a connection error:
如果看到連接錯誤：

1. **Check if backend is running** / 檢查後端是否正在運行
   ```bash
   cd backend
   ./start.sh
   # or for production
   ./start-prod.sh
   ```

2. **Verify API URL in .env** / 驗證 .env 中的 API URL
   ```env
   VITE_API_BASE_URL=http://localhost:8000/api
   ```

3. **Check CORS settings** / 檢查 CORS 設定
   - Backend must allow frontend origin / 後端必須允許前端來源
   - Default: `http://localhost:5173` / 預設：`http://localhost:5173`

4. **Restart development server** / 重啟開發服務器
   ```bash
   cd frontend
   pnpm dev
   ```

### Wrong API URL Displayed / 顯示錯誤的 API URL

1. Check `.env` file exists / 檢查 `.env` 文件是否存在
   ```bash
   ls frontend/.env
   ```

2. Verify environment variable / 驗證環境變數
   ```bash
   cat frontend/.env | grep VITE_API_BASE_URL
   ```

3. Restart Vite dev server / 重啟 Vite 開發服務器
   - Environment variables are loaded at startup / 環境變數在啟動時載入
   - Changes require restart / 更改需要重啟

## Component API / 組件 API

### Props

```typescript
interface ApiInfoProps {
  onClose?: () => void;  // Optional callback when closing
                         // 關閉時的可選回調
}
```

### Usage Example / 使用範例

```tsx
import { ApiInfo } from './components/ApiInfo';
import { useState } from 'react';

function MyApp() {
  const [showApiInfo, setShowApiInfo] = useState(false);

  return (
    <>
      <button onClick={() => setShowApiInfo(true)}>
        Show API Info
      </button>
      
      {showApiInfo && (
        <ApiInfo onClose={() => setShowApiInfo(false)} />
      )}
    </>
  );
}
```

## Styling / 樣式

The component uses inline styles with a dark theme that matches the game UI:
組件使用內聯樣式，採用與遊戲 UI 匹配的深色主題：

- Background: Dark gray (`#1a1a2e`) / 背景：深灰色
- Accent color: Cyan (`#00d4ff`) / 強調色：青色
- Status indicators: Green for healthy / 狀態指示器：健康狀態為綠色
- Modal overlay: Semi-transparent black / 彈窗覆蓋層：半透明黑色

## Technical Details / 技術細節

### State Management / 狀態管理
- Uses React Hooks (useState, useEffect) / 使用 React Hooks
- Fetches data on mount / 掛載時獲取資料
- Handles loading and error states / 處理載入和錯誤狀態

### API Calls / API 調用
```typescript
// Fetches root endpoint
GET ${API_ROOT}/

// Fetches health endpoint
GET ${API_ROOT}/health
```

### Environment Variables / 環境變數
```typescript
const API_BASE_URL = (import.meta as any).env?.VITE_API_BASE_URL 
  || 'http://localhost:8000/api';
```

## Best Practices / 最佳實踐

1. **Check API info before playing** / 遊戲前檢查 API 資訊
   - Ensure backend is connected / 確保後端已連接
   - Verify correct environment / 驗證正確的環境

2. **Use for debugging** / 用於調試
   - Quick way to check connection / 快速檢查連接的方式
   - See which endpoints are available / 查看可用的端點

3. **Share with team** / 與團隊共享
   - Clear documentation links / 清晰的文檔連結
   - Easy to verify setup / 易於驗證設定

## Related Files / 相關文件

- `frontend/components/ApiInfo.tsx` - Component implementation / 組件實現
- `frontend/App.tsx` - Integration / 整合
- `frontend/.env` - Environment configuration / 環境配置
- `frontend/env.template` - Environment template / 環境模板
- `frontend/ENV_SETUP.md` - Environment setup guide / 環境設定指南

## Support / 支援

For issues or questions:
如有問題或疑問：

1. Check the error message in the modal / 檢查彈窗中的錯誤訊息
2. Review backend logs / 查看後端日誌
3. Verify environment configuration / 驗證環境配置
4. Check CORS settings / 檢查 CORS 設定

