"""Pydantic schemas for request/response validation."""
from pydantic import BaseModel, Field, ConfigDict
from datetime import datetime
from typing import Literal


class ScoreCreate(BaseModel):
    """Schema for creating a new score."""
    player_name: str = Field(..., min_length=1, max_length=100, description="Player name")
    score: int = Field(..., ge=0, description="Game score")
    lines: int = Field(..., ge=0, description="Number of lines cleared")
    mode: Literal["1P", "2P"] = Field(..., description="Game mode (1P or 2P)")

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "player_name": "Player1",
                "score": 1500,
                "lines": 15,
                "mode": "1P"
            }
        }
    )


class ScoreResponse(BaseModel):
    """Schema for score response."""
    id: int
    player_name: str
    score: int
    lines: int
    mode: str
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class LeaderboardStats(BaseModel):
    """Schema for leaderboard statistics."""
    total_games: int = Field(..., description="Total number of games played")
    highest_score: int = Field(..., description="Highest score achieved")
    average_score: float = Field(..., description="Average score across all games")
    total_lines_cleared: int = Field(..., description="Total lines cleared across all games")

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "total_games": 100,
                "highest_score": 5000,
                "average_score": 1250.5,
                "total_lines_cleared": 1500
            }
        }
    )

