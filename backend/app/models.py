"""SQLAlchemy database models."""
from sqlalchemy import Column, Integer, String, DateTime, Enum, Index
from sqlalchemy.sql import func
from app.database import Base
import enum


class GameMode(str, enum.Enum):
    """Game mode enumeration."""
    ONE_PLAYER = "1P"
    TWO_PLAYER = "2P"


class Game(Base):
    """Game model for storing game results (1 or 2 players per game)."""
    __tablename__ = "games"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    mode = Column(Enum(GameMode), nullable=False, index=True)
    
    # Player 1 data (always present)
    player1_name = Column(String(100), nullable=False)
    player1_score = Column(Integer, nullable=False, index=True)
    player1_lines = Column(Integer, nullable=False)
    
    # Player 2 data (nullable, only for 2P mode)
    player2_name = Column(String(100), nullable=True)
    player2_score = Column(Integer, nullable=True, index=True)
    player2_lines = Column(Integer, nullable=True)
    
    # Winner indication: 1, 2, or NULL (for 1P mode or tie)
    winner = Column(Integer, nullable=True)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    # Create composite indexes for better query performance
    __table_args__ = (
        Index('idx_player1_score_mode', 'player1_score', 'mode', 'created_at'),
        Index('idx_player2_score_mode', 'player2_score', 'mode', 'created_at'),
        Index('idx_mode_created', 'mode', 'created_at'),
    )

    def __repr__(self):
        if self.mode == GameMode.TWO_PLAYER:
            return f"<Game(id={self.id}, mode={self.mode}, p1={self.player1_name}:{self.player1_score}, p2={self.player2_name}:{self.player2_score})>"
        return f"<Game(id={self.id}, mode={self.mode}, player={self.player1_name}, score={self.player1_score})>"

