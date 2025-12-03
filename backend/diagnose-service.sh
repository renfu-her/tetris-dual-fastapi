#!/bin/bash
# Systemd Service 診斷腳本

echo "🔍 Tetris Dual Backend - Service 診斷工具"
echo "=========================================="
echo ""

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. 檢查 uv 是否安裝
echo "1️⃣  檢查 uv 安裝..."
if command -v uv &> /dev/null; then
    echo -e "${GREEN}✓${NC} uv 已安裝: $(which uv)"
    uv --version
else
    echo -e "${RED}✗${NC} uv 未安裝或不在 PATH 中"
    echo "   安裝方式: curl -LsSf https://astral.sh/uv/install.sh | sh"
fi
echo ""

# 2. 檢查工作目錄
echo "2️⃣  檢查工作目錄..."
WORK_DIR="/home/ai-tracks-tetris-game/htdocs/tetris-game.ai-tracks.com/backend"
if [ -d "$WORK_DIR" ]; then
    echo -e "${GREEN}✓${NC} 工作目錄存在: $WORK_DIR"
    ls -la "$WORK_DIR" | head -5
else
    echo -e "${RED}✗${NC} 工作目錄不存在: $WORK_DIR"
fi
echo ""

# 3. 檢查 .venv
echo "3️⃣  檢查虛擬環境..."
if [ -d "$WORK_DIR/.venv" ]; then
    echo -e "${GREEN}✓${NC} .venv 存在"
    echo "   Python: $WORK_DIR/.venv/bin/python"
else
    echo -e "${RED}✗${NC} .venv 不存在"
    echo "   執行: cd $WORK_DIR && uv sync"
fi
echo ""

# 4. 檢查依賴
echo "4️⃣  檢查依賴安裝..."
if [ -f "$WORK_DIR/pyproject.toml" ]; then
    echo -e "${GREEN}✓${NC} pyproject.toml 存在"
    cd "$WORK_DIR"
    if uv run python -c "import gunicorn; print(f'Gunicorn: {gunicorn.__version__}')" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Gunicorn 已安裝"
    else
        echo -e "${RED}✗${NC} Gunicorn 未安裝"
        echo "   執行: cd $WORK_DIR && uv sync"
    fi
    
    if uv run python -c "import uvicorn; print(f'Uvicorn: {uvicorn.__version__}')" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Uvicorn 已安裝"
    else
        echo -e "${RED}✗${NC} Uvicorn 未安裝"
    fi
    
    if uv run python -c "import fastapi; print(f'FastAPI: {fastapi.__version__}')" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} FastAPI 已安裝"
    else
        echo -e "${RED}✗${NC} FastAPI 未安裝"
    fi
else
    echo -e "${RED}✗${NC} pyproject.toml 不存在"
fi
echo ""

# 5. 檢查日誌目錄
echo "5️⃣  檢查日誌目錄..."
LOG_DIR="/var/log/uvicorn"
if [ -d "$LOG_DIR" ]; then
    echo -e "${GREEN}✓${NC} 日誌目錄存在: $LOG_DIR"
    ls -la "$LOG_DIR"
    
    # 檢查權限
    if [ -w "$LOG_DIR" ]; then
        echo -e "${GREEN}✓${NC} 日誌目錄可寫入"
    else
        echo -e "${YELLOW}⚠${NC}  日誌目錄沒有寫入權限"
        echo "   執行: sudo chown -R ai-tracks-tetris-game:ai-tracks-tetris-game $LOG_DIR"
    fi
else
    echo -e "${RED}✗${NC} 日誌目錄不存在: $LOG_DIR"
    echo "   執行: sudo mkdir -p $LOG_DIR && sudo chown ai-tracks-tetris-game:ai-tracks-tetris-game $LOG_DIR"
fi
echo ""

# 6. 檢查使用者
echo "6️⃣  檢查使用者..."
if id "ai-tracks-tetris-game" &>/dev/null; then
    echo -e "${GREEN}✓${NC} 使用者存在: ai-tracks-tetris-game"
    id ai-tracks-tetris-game
else
    echo -e "${RED}✗${NC} 使用者不存在: ai-tracks-tetris-game"
fi
echo ""

# 7. 檢查 service 檔案
echo "7️⃣  檢查 systemd service..."
SERVICE_FILE="/etc/systemd/system/tetris-dual-backend.service"
if [ -f "$SERVICE_FILE" ]; then
    echo -e "${GREEN}✓${NC} Service 檔案存在: $SERVICE_FILE"
    echo "   內容預覽："
    grep "ExecStart" "$SERVICE_FILE"
else
    echo -e "${RED}✗${NC} Service 檔案不存在: $SERVICE_FILE"
    echo "   執行: sudo cp tetris-dual-backend.service /etc/systemd/system/"
fi
echo ""

# 8. 檢查服務狀態
echo "8️⃣  檢查服務狀態..."
if systemctl list-unit-files | grep -q "tetris-dual-backend.service"; then
    echo -e "${GREEN}✓${NC} 服務已註冊"
    sudo systemctl status tetris-dual-backend.service --no-pager -l || true
else
    echo -e "${RED}✗${NC} 服務未註冊"
    echo "   執行: sudo systemctl daemon-reload"
fi
echo ""

# 9. 測試手動啟動
echo "9️⃣  測試手動啟動（僅測試命令可用性）..."
cd "$WORK_DIR" 2>/dev/null
if uv run gunicorn --version &>/dev/null; then
    echo -e "${GREEN}✓${NC} uv run gunicorn 可執行"
else
    echo -e "${RED}✗${NC} uv run gunicorn 無法執行"
fi
echo ""

# 10. 查看最近的錯誤日誌
echo "🔟 最近的錯誤日誌..."
if [ -f "/var/log/uvicorn/tetris-game-error.log" ]; then
    echo "最後 10 行錯誤日誌："
    tail -n 10 /var/log/uvicorn/tetris-game-error.log
else
    echo "錯誤日誌檔案不存在"
fi
echo ""

# 11. 查看 systemd 日誌
echo "1️⃣1️⃣ Systemd 日誌（最後 20 行）..."
sudo journalctl -u tetris-dual-backend.service -n 20 --no-pager || echo "無法讀取 systemd 日誌"
echo ""

echo "=========================================="
echo "🎯 診斷完成！"
echo ""
echo "💡 建議的修正步驟："
echo "1. 確保使用 'uv run gunicorn' 而不是直接路徑"
echo "2. 檢查日誌目錄權限"
echo "3. 確認所有依賴已安裝 (uv sync)"
echo "4. 手動測試命令是否可執行"
echo "5. 查看 systemd 日誌了解詳細錯誤"
echo ""
echo "📚 詳細文檔: backend/SYSTEMD_SETUP.md"



