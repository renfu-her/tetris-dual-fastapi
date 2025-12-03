"""FastAPI main application."""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import os
from dotenv import load_dotenv

from app.database import init_db
from app.routers import scores as games_router, leaderboard

# Load environment variables
load_dotenv()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan manager."""
    # Startup: Initialize database tables
    print(">>> Starting up Tetris Dual Backend...")
    init_db()
    print(">>> Database initialized successfully")
    yield
    # Shutdown
    print(">>> Shutting down Tetris Dual Backend...")


# Create FastAPI application
app = FastAPI(
    title="Tetris Dual API",
    description="Backend API for Tetris Dual game with score tracking and leaderboard",
    version="1.0.0",
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc"
)

# Configure CORS
# 生產環境使用 Nginx 反向代理，不需要 CORS
# 開發環境需要 CORS 以支援本地開發
env_mode = os.getenv("ENV", "development")

if env_mode == "development":
    # 開發環境：啟用 CORS
    cors_origins = [
        "http://localhost:3000",
        "http://localhost:5173",
        "http://localhost:8098",
        "http://127.0.0.1:3000",
        "http://127.0.0.1:5173",
        "http://127.0.0.1:8098",
    ]
    
    print(f">>> 開發模式: CORS 已啟用，允許的來源: {cors_origins}")
    
    app.add_middleware(
        CORSMiddleware,
        allow_origins=cors_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
else:
    # 生產環境：不需要 CORS（使用 Nginx 反向代理）
    print(f">>> 生產模式: CORS 已停用（使用 Nginx 反向代理）")

# Include routers
app.include_router(games_router.router)
app.include_router(leaderboard.router)


@app.get("/", tags=["root"])
async def root():
    """Root endpoint - API health check."""
    return {
        "status": "online",
        "message": "Tetris Dual Backend API",
        "version": "1.0.0",
        "docs": "/docs"
    }


@app.get("/health", tags=["root"])
async def health_check():
    """Health check endpoint."""
    return {
        "status": "healthy",
        "service": "tetris-dual-backend"
    }

