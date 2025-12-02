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
cors_origins = os.getenv("CORS_ORIGINS", "http://localhost:5173").split(",")
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

