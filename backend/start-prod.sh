#!/bin/bash
# Production start script for Tetris Dual Backend with Gunicorn

echo "🎮 Starting Tetris Dual Backend (Production Mode)"
echo ""

# Check if uv is installed
if ! command -v uv &> /dev/null
then
    echo "❌ uv is not installed. Please install it first:"
    echo "   curl -LsSf https://astral.sh/uv/install.sh | sh"
    exit 1
fi

# Check if .env exists
if [ ! -f .env ]; then
    echo "⚠️  .env file not found. Creating from .env.example..."
    cp .env.example .env
    echo "✅ Created .env file"
fi

# Sync dependencies
echo "📦 Syncing dependencies..."
uv sync

# Start with Gunicorn
echo ""
echo "🚀 Starting production server with Gunicorn..."
echo "📝 API Documentation: http://localhost:8000/docs"
echo "🔧 Health Check: http://localhost:8000/health"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Start Gunicorn with Uvicorn workers
uv run gunicorn app.main:app \
    --config gunicorn.conf.py \
    --worker-class uvicorn.workers.UvicornWorker

