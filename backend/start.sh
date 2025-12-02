#!/bin/bash
# Start script for Tetris Dual Backend

echo "🎮 Starting Tetris Dual Backend..."
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

# Start the server
echo ""
echo "🚀 Starting FastAPI server..."
echo "📝 API Documentation: http://localhost:8000/docs"
echo "🔧 Health Check: http://localhost:8000/health"
echo ""
uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

