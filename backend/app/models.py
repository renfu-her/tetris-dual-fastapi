"""SQLAlchemy database models."""
from sqlalchemy import Column, Integer, String, DateTime, Enum, Index
from sqlalchemy.sql import func
from app.database import Base
import enum


class GameMode(str, enum.Enum):
    """Game mode enumeration."""
    ONE_PLAYER = "1P"
    TWO_PLAYER = "2P"


class Score(Base):
    """Score model for storing game results."""
    __tablename__ = "scores"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    player_name = Column(String(100), nullable=False)
    score = Column(Integer, nullable=False, index=True)
    lines = Column(Integer, nullable=False)
    mode = Column(Enum(GameMode), nullable=False, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    # Create composite index for better query performance
    __table_args__ = (
        Index('idx_score_mode_created', 'score', 'mode', 'created_at'),
    )

    def __repr__(self):
        return f"<Score(id={self.id}, player={self.player_name}, score={self.score}, mode={self.mode})>"

