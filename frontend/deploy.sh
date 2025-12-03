#!/bin/bash
# Frontend 部署腳本

echo "🎮 Tetris Dual - Frontend 部署"
echo "==============================="
echo ""

# 顏色定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# 檢查是否在 frontend 目錄
if [ ! -f "package.json" ]; then
    echo -e "${RED}錯誤: 請在 frontend 目錄中執行此腳本${NC}"
    exit 1
fi

# Step 1: 檢查 .env 配置
echo -e "${BLUE}Step 1: 檢查環境配置${NC}"
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚠ .env 文件不存在，從 env.template 創建${NC}"
    cp env.template .env
    echo -e "${GREEN}✓${NC} 已創建 .env"
fi

echo "當前配置："
grep "VITE_API_BASE_URL" .env || echo "VITE_API_BASE_URL=未設定"
echo ""

# Step 2: 安裝依賴
echo -e "${BLUE}Step 2: 安裝依賴${NC}"
if command -v pnpm &> /dev/null; then
    echo "使用 pnpm 安裝..."
    pnpm install
elif command -v npm &> /dev/null; then
    echo "使用 npm 安裝..."
    npm install
else
    echo -e "${RED}錯誤: 未找到 npm 或 pnpm${NC}"
    exit 1
fi
echo ""

# Step 3: 構建生產版本
echo -e "${BLUE}Step 3: 構建生產版本${NC}"
echo "開始構建..."

if command -v pnpm &> /dev/null; then
    pnpm build
else
    npm run build
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} 構建成功"
else
    echo -e "${RED}✗${NC} 構建失敗"
    exit 1
fi
echo ""

# Step 4: 檢查構建輸出
echo -e "${BLUE}Step 4: 檢查構建輸出${NC}"
if [ -d "dist" ]; then
    echo -e "${GREEN}✓${NC} dist 目錄存在"
    echo "構建文件列表："
    ls -lh dist/
    echo ""
    echo "dist/assets 內容："
    ls -lh dist/assets/ 2>/dev/null || echo "assets 目錄不存在或為空"
else
    echo -e "${RED}✗${NC} dist 目錄不存在"
    exit 1
fi
echo ""

# Step 5: 顯示部署說明
echo -e "${BLUE}Step 5: 部署到生產服務器${NC}"
echo "==============================="
echo ""
echo "📦 方法 1: 使用 rsync 同步（推薦）"
echo "-----------------------------------"
echo "在本地執行："
echo ""
echo -e "${YELLOW}rsync -avz --delete dist/ your-user@tetris-game.ai-tracks.com:/home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/frontend/dist/${NC}"
echo ""
echo "或者："
echo ""
echo -e "${YELLOW}rsync -avz --delete dist/ your-user@your-server-ip:/path/to/frontend/dist/${NC}"
echo ""

echo "📦 方法 2: 使用 SCP 複製"
echo "-----------------------------------"
echo -e "${YELLOW}scp -r dist/* your-user@tetris-game.ai-tracks.com:/home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/frontend/dist/${NC}"
echo ""

echo "📦 方法 3: 使用 Git（如果服務器有配置）"
echo "-----------------------------------"
echo "1. 提交構建文件到 git："
echo -e "   ${YELLOW}git add dist/${NC}"
echo -e "   ${YELLOW}git commit -m \"Update build\"${NC}"
echo -e "   ${YELLOW}git push${NC}"
echo ""
echo "2. 在服務器上："
echo -e "   ${YELLOW}cd /home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com${NC}"
echo -e "   ${YELLOW}git pull${NC}"
echo ""

echo "📦 方法 4: 手動上傳"
echo "-----------------------------------"
echo "1. 將 dist 目錄打包："
echo -e "   ${YELLOW}cd ..${NC}"
echo -e "   ${YELLOW}tar -czf frontend-dist.tar.gz frontend/dist/${NC}"
echo ""
echo "2. 上傳到服務器"
echo "3. 在服務器上解壓到正確位置"
echo ""

echo "==============================="
echo ""
echo -e "${GREEN}✅ 構建完成！${NC}"
echo ""
echo "⚠️  重要提醒："
echo "1. 確保 .env 中的 VITE_API_BASE_URL 指向正確的後端"
echo "2. 部署後，清除瀏覽器緩存"
echo "3. 檢查 Nginx 配置是否正確"
echo ""

