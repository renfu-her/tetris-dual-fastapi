#!/bin/bash
# 快速檢查生產環境狀態

echo "🎮 Tetris Dual - 生產環境快速檢查"
echo "===================================="
echo ""

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 計數器
PASS=0
FAIL=0
WARN=0

# 檢查函數
check() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $1"
        ((PASS++))
    else
        echo -e "${RED}✗${NC} $1"
        ((FAIL++))
    fi
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARN++))
}

info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

echo "1. 檢查 MySQL 狀態..."
sudo systemctl is-active --quiet mysql
check "MySQL 服務運行中"
echo ""

echo "2. 檢查後端服務狀態..."
sudo systemctl is-active --quiet tetris-dual-backend.service
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} 後端服務運行中"
    ((PASS++))
    
    # 顯示服務詳情
    info "服務啟動時間: $(sudo systemctl show tetris-dual-backend.service -p ActiveEnterTimestamp --value)"
    info "主進程 PID: $(sudo systemctl show tetris-dual-backend.service -p MainPID --value)"
else
    echo -e "${RED}✗${NC} 後端服務未運行"
    ((FAIL++))
    warn "執行: sudo systemctl start tetris-dual-backend.service"
fi
echo ""

echo "3. 檢查端口監聽..."
if sudo netstat -tlnp 2>/dev/null | grep -q "127.0.0.1:8098"; then
    echo -e "${GREEN}✓${NC} 端口 8098 正在監聽"
    ((PASS++))
    sudo netstat -tlnp 2>/dev/null | grep "127.0.0.1:8098" | head -1
elif sudo ss -tlnp 2>/dev/null | grep -q "127.0.0.1:8098"; then
    echo -e "${GREEN}✓${NC} 端口 8098 正在監聽"
    ((PASS++))
    sudo ss -tlnp 2>/dev/null | grep "127.0.0.1:8098" | head -1
else
    echo -e "${RED}✗${NC} 端口 8098 未監聽"
    ((FAIL++))
    warn "後端服務可能未正常啟動"
fi
echo ""

echo "4. 檢查本地 API..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8098/ 2>/dev/null)
if [ "$RESPONSE" = "200" ]; then
    echo -e "${GREEN}✓${NC} 本地 API 響應正常 (HTTP 200)"
    ((PASS++))
    info "API 內容: $(curl -s http://127.0.0.1:8098/ 2>/dev/null)"
else
    echo -e "${RED}✗${NC} 本地 API 無響應 (HTTP $RESPONSE)"
    ((FAIL++))
fi
echo ""

echo "5. 檢查外部訪問..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" https://tetris-game.ai-tracks.com/ 2>/dev/null)
if [ "$RESPONSE" = "200" ]; then
    echo -e "${GREEN}✓${NC} 外部訪問正常 (HTTP 200)"
    ((PASS++))
elif [ "$RESPONSE" = "500" ]; then
    echo -e "${RED}✗${NC} 外部訪問返回 500 錯誤"
    ((FAIL++))
    warn "可能是 Nginx 配置問題或後端未啟動"
else
    echo -e "${YELLOW}⚠${NC} 外部訪問異常 (HTTP $RESPONSE)"
    ((WARN++))
fi
echo ""

echo "6. 檢查 Nginx 狀態..."
sudo systemctl is-active --quiet nginx
check "Nginx 服務運行中"

sudo nginx -t &>/dev/null
check "Nginx 配置語法正確"
echo ""

echo "7. 檢查日誌目錄..."
if [ -d "/var/log/uvicorn" ]; then
    echo -e "${GREEN}✓${NC} 日誌目錄存在"
    ((PASS++))
    
    if [ -w "/var/log/uvicorn" ]; then
        echo -e "${GREEN}✓${NC} 日誌目錄可寫入"
        ((PASS++))
    else
        echo -e "${YELLOW}⚠${NC} 日誌目錄權限不足"
        ((WARN++))
    fi
    
    info "最近修改: $(ls -lht /var/log/uvicorn | head -2 | tail -1)"
else
    echo -e "${RED}✗${NC} 日誌目錄不存在"
    ((FAIL++))
fi
echo ""

echo "8. 檢查最近的錯誤..."
if [ -f "/var/log/uvicorn/tetris-game-error.log" ]; then
    ERROR_COUNT=$(tail -n 50 /var/log/uvicorn/tetris-game-error.log 2>/dev/null | grep -i "error\|exception\|traceback" | wc -l)
    if [ "$ERROR_COUNT" -gt 0 ]; then
        echo -e "${YELLOW}⚠${NC} 發現 $ERROR_COUNT 行錯誤日誌"
        ((WARN++))
        echo ""
        echo "最後 10 行錯誤日誌："
        echo "-------------------"
        tail -n 10 /var/log/uvicorn/tetris-game-error.log
        echo "-------------------"
    else
        echo -e "${GREEN}✓${NC} 最近沒有錯誤日誌"
        ((PASS++))
    fi
else
    warn "錯誤日誌文件不存在"
fi
echo ""

echo "===================================="
echo "📊 檢查結果統計"
echo "===================================="
echo -e "${GREEN}✓ 通過: $PASS${NC}"
echo -e "${YELLOW}⚠ 警告: $WARN${NC}"
echo -e "${RED}✗ 失敗: $FAIL${NC}"
echo ""

if [ $FAIL -eq 0 ] && [ $WARN -eq 0 ]; then
    echo -e "${GREEN}🎉 所有檢查通過！系統運行正常！${NC}"
    exit 0
elif [ $FAIL -eq 0 ]; then
    echo -e "${YELLOW}⚠️  有一些警告，但系統基本正常${NC}"
    exit 0
else
    echo -e "${RED}❌ 發現問題，需要修復${NC}"
    echo ""
    echo "💡 建議的修復步驟："
    echo "1. 查看詳細診斷: ./diagnose-service.sh"
    echo "2. 重啟服務: sudo systemctl restart tetris-dual-backend.service"
    echo "3. 查看實時日誌: sudo journalctl -u tetris-dual-backend.service -f"
    echo "4. 參考修復指南: cat QUICK_FIX.md"
    exit 1
fi

