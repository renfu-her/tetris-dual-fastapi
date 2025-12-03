@echo off
REM Production start script for Tetris Dual Backend with Gunicorn (Windows)

echo 🎮 Starting Tetris Dual Backend (Production Mode)
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

REM Start with Gunicorn
echo.
echo 🚀 Starting production server with Gunicorn...
echo 📝 API Documentation: http://localhost:8000/docs
echo 🔧 Health Check: http://localhost:8000/health
echo.
echo Press Ctrl+C to stop the server
echo.

REM Start Gunicorn with Uvicorn workers
uv run gunicorn app.main:app ^
    --config gunicorn.conf.py ^
    --worker-class uvicorn.workers.UvicornWorker

