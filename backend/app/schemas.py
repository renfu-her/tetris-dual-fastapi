"""Pydantic schemas for request/response validation."""
from pydantic import BaseModel, Field, ConfigDict, field_validator
from datetime import datetime
from typing import Literal, Optional


class PlayerData(BaseModel):
    """Schema for individual player data."""
    name: str = Field(..., min_length=1, max_length=100, description="Player name")
    score: int = Field(..., ge=0, description="Player score")
    lines: int = Field(..., ge=0, description="Lines cleared by player")


class GameCreate(BaseModel):
    """Schema for creating a new game record."""
    mode: Literal["1P", "2P"] = Field(..., description="Game mode (1P or 2P)")
    player1: PlayerData = Field(..., description="Player 1 data")
    player2: Optional[PlayerData] = Field(None, description="Player 2 data (required for 2P mode)")
    winner: Optional[Literal[1, 2]] = Field(None, description="Winner: 1 or 2 (for 2P mode)")

    @field_validator('player2')
    @classmethod
    def validate_player2(cls, v, info):
        """Validate that player2 is provided for 2P mode."""
        mode = info.data.get('mode')
        if mode == '2P' and v is None:
            raise ValueError('player2 is required for 2P mode')
        if mode == '1P' and v is not None:
            raise ValueError('player2 should not be provided for 1P mode')
        return v

    model_config = ConfigDict(
        json_schema_extra={
            "examples": [
                {
                    "mode": "1P",
                    "player1": {"name": "Alice", "score": 1500, "lines": 15},
                    "player2": None,
                    "winner": None
                },
                {
                    "mode": "2P",
                    "player1": {"name": "Alice", "score": 2000, "lines": 20},
                    "player2": {"name": "Bob", "score": 1800, "lines": 18},
                    "winner": 1
                }
            ]
        }
    )


class GameResponse(BaseModel):
    """Schema for game response."""
    id: int
    mode: str
    player1_name: str
    player1_score: int
    player1_lines: int
    player2_name: Optional[str] = None
    player2_score: Optional[int] = None
    player2_lines: Optional[int] = None
    winner: Optional[int] = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class LeaderboardEntry(BaseModel):
    """Schema for leaderboard entry (flattened player view)."""
    game_id: int
    player_name: str
    score: int
    lines: int
    mode: str
    is_winner: Optional[bool] = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class LeaderboardStats(BaseModel):
    """Schema for leaderboard statistics."""
    total_games: int = Field(..., description="Total number of games played")
    total_1p_games: int = Field(..., description="Total 1P games")
    total_2p_games: int = Field(..., description="Total 2P games")
    highest_score: int = Field(..., description="Highest score achieved")
    average_score: float = Field(..., description="Average score across all games")
    total_lines_cleared: int = Field(..., description="Total lines cleared across all games")

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "total_games": 100,
                "total_1p_games": 60,
                "total_2p_games": 40,
                "highest_score": 5000,
                "average_score": 1250.5,
                "total_lines_cleared": 1500
            }
        }
    )

