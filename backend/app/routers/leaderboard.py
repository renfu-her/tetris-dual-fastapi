"""API routes for leaderboard."""
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from app.database import get_db
from app.schemas import LeaderboardEntry, LeaderboardStats
from app import crud

router = APIRouter(
    prefix="/api/leaderboard",
    tags=["leaderboard"]
)


@router.get(
    "",
    response_model=List[LeaderboardEntry],
    summary="Get leaderboard rankings",
    description="Retrieve top player performances with optional filtering by game mode"
)
def get_leaderboard(
    mode: Optional[str] = Query(
        "all",
        description="Filter by game mode: '1P', '2P', or 'all'",
        pattern="^(1P|2P|all)$"
    ),
    limit: int = Query(
        10,
        ge=1,
        le=100,
        description="Number of results to return (1-100)"
    ),
    db: Session = Depends(get_db)
):
    """
    Get leaderboard rankings sorted by score (highest first).
    Returns individual player performances from all games.
    
    - **mode**: Filter by game mode ('1P', '2P', or 'all' for no filter)
    - **limit**: Maximum number of results (default: 10, max: 100)
    """
    entries = crud.get_leaderboard(db, mode=mode, limit=limit)
    return entries


@router.get(
    "/stats",
    response_model=LeaderboardStats,
    summary="Get game statistics",
    description="Retrieve overall statistics across all games"
)
def get_stats(db: Session = Depends(get_db)):
    """
    Get comprehensive statistics for all games.
    
    Returns:
    - Total number of games played
    - Total 1P and 2P games
    - Highest score achieved
    - Average score across all players
    - Total lines cleared
    """
    stats = crud.get_leaderboard_stats(db)
    return stats

