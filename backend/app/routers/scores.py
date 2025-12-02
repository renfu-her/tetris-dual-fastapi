"""API routes for game management."""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas import GameCreate, GameResponse
from app import crud

router = APIRouter(
    prefix="/api/games",
    tags=["games"]
)


@router.post(
    "",
    response_model=GameResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Save a game record",
    description="Create a new game record for a completed game (1 or 2 players)"
)
def create_game(
    game_data: GameCreate,
    db: Session = Depends(get_db)
):
    """
    Save a new game record to the database.
    
    - **mode**: Game mode ("1P" or "2P")
    - **player1**: Player 1 data (name, score, lines)
    - **player2**: Player 2 data (required for 2P mode, null for 1P)
    - **winner**: Winner indicator (1 or 2 for 2P mode, null for 1P)
    """
    try:
        db_game = crud.create_game(db, game_data)
        return db_game
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to save game: {str(e)}"
        )

