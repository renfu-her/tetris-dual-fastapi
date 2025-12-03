#!/bin/bash
# 修復 CORS 配置的快速腳本

echo "🔧 修復 CORS 配置"
echo "=================="
echo ""

BACKEND_DIR="/home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/backend"

# 顏色定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 檢查是否在正確的目錄
if [ ! -f "app/main.py" ]; then
    echo -e "${RED}錯誤: 請在 backend 目錄中執行此腳本${NC}"
    exit 1
fi

# 備份現有的 .env
if [ -f ".env" ]; then
    echo "📦 備份現有的 .env..."
    cp .env .env.backup.$(date +%Y%m%d_%H%M%S)
    echo -e "${GREEN}✓${NC} 已備份到 .env.backup.*"
    echo ""
fi

# 檢查 .env 是否存在
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚠${NC}  .env 文件不存在，創建新文件..."
    touch .env
fi

# 檢查是否已經有 CORS_ORIGINS 設定
if grep -q "CORS_ORIGINS" .env; then
    echo "📝 更新現有的 CORS_ORIGINS..."
    # 移除舊的設定
    sed -i.bak '/CORS_ORIGINS/d' .env
fi

# 添加正確的 CORS 設定
echo "" >> .env
echo "# CORS Origins - 允許的前端來源" >> .env
echo "# 多個來源用逗號分隔，不要有空格" >> .env
echo "CORS_ORIGINS=https://tetris-game.ai-tracks.com,http://localhost:3000,http://localhost:5173,http://localhost:8098" >> .env

echo -e "${GREEN}✓${NC} 已添加 CORS 配置"
echo ""

# 顯示當前配置
echo "📋 當前 CORS 配置："
echo "-------------------"
grep "CORS_ORIGINS" .env
echo "-------------------"
echo ""

# 提示重啟服務
echo "🔄 下一步："
echo "1. 檢查配置是否正確"
echo "2. 重啟服務使配置生效："
echo "   ${YELLOW}sudo systemctl restart tetris-dual-backend.service${NC}"
echo ""
echo "3. 檢查服務狀態："
echo "   ${YELLOW}sudo systemctl status tetris-dual-backend.service${NC}"
echo ""
echo "4. 查看日誌確認 CORS 配置已載入："
echo "   ${YELLOW}sudo journalctl -u tetris-dual-backend.service -n 20${NC}"
echo "   應該看到: >>> CORS允許的來源: [...]"
echo ""

# 詢問是否立即重啟
read -p "是否立即重啟服務？(y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔄 重啟服務..."
    sudo systemctl restart tetris-dual-backend.service
    sleep 2
    echo ""
    echo "📊 服務狀態："
    sudo systemctl status tetris-dual-backend.service --no-pager -l
    echo ""
    echo "📝 最近日誌："
    sudo journalctl -u tetris-dual-backend.service -n 10 --no-pager
fi

echo ""
echo -e "${GREEN}✅ 完成！${NC}"

