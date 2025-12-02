"""API routes for score management."""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas import ScoreCreate, ScoreResponse
from app import crud

router = APIRouter(
    prefix="/api/scores",
    tags=["scores"]
)


@router.post(
    "",
    response_model=ScoreResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Save a game score",
    description="Create a new score record for a completed game"
)
def create_score(
    score_data: ScoreCreate,
    db: Session = Depends(get_db)
):
    """
    Save a new game score to the database.
    
    - **player_name**: Name of the player (1-100 characters)
    - **score**: Game score (non-negative integer)
    - **lines**: Number of lines cleared (non-negative integer)
    - **mode**: Game mode ("1P" for single player or "2P" for two players)
    """
    try:
        db_score = crud.create_score(db, score_data)
        return db_score
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to save score: {str(e)}"
        )

