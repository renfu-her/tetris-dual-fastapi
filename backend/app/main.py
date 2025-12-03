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
# 從環境變數讀取，如果沒有設定則使用預設值
cors_origins_env = os.getenv(
    "CORS_ORIGINS", 
    "https://tetris-game.ai-tracks.com,http://localhost:3000,http://localhost:5173,http://localhost:8098"
)
cors_origins = [origin.strip() for origin in cors_origins_env.split(",")]

# 在開發環境中額外允許 127.0.0.1
if os.getenv("ENV", "development") == "development":
    cors_origins.extend([
        "http://127.0.0.1:3000",
        "http://127.0.0.1:5173",
        "http://127.0.0.1:8098",
    ])

print(f">>> CORS允許的來源: {cors_origins}")

app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

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

