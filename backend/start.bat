@echo off
REM Start script for Tetris Dual Backend (Windows)

echo 🎮 Starting Tetris Dual Backend...
echo.

REM Check if .env exists
if not exist .env (
    echo ⚠️  .env file not found. Creating from .env.example...
    copy .env.example .env
    echo ✅ Created .env file
)

REM Sync dependencies
echo 📦 Syncing dependencies...
uv sync

REM Start the server
echo.
echo 🚀 Starting FastAPI server...
echo 📝 API Documentation: http://localhost:8000/docs
echo 🔧 Health Check: http://localhost:8000/health
echo.
uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

