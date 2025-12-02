"""CRUD operations for database models."""
from sqlalchemy.orm import Session
from sqlalchemy import func, desc
from app.models import Score, GameMode
from app.schemas import ScoreCreate, LeaderboardStats
from typing import List, Optional


def create_score(db: Session, score_data: ScoreCreate) -> Score:
    """Create a new score record."""
    db_score = Score(
        player_name=score_data.player_name,
        score=score_data.score,
        lines=score_data.lines,
        mode=GameMode(score_data.mode)
    )
    db.add(db_score)
    db.commit()
    db.refresh(db_score)
    return db_score


def get_leaderboard(
    db: Session, 
    mode: Optional[str] = None, 
    limit: int = 10
) -> List[Score]:
    """Get leaderboard with optional mode filter."""
    query = db.query(Score)
    
    # Apply mode filter if specified
    if mode and mode != "all":
        try:
            game_mode = GameMode(mode)
            query = query.filter(Score.mode == game_mode)
        except ValueError:
            # Invalid mode, return empty list
            return []
    
    # Order by score descending and limit results
    query = query.order_by(desc(Score.score))
    query = query.limit(limit)
    
    return query.all()


def get_leaderboard_stats(db: Session) -> LeaderboardStats:
    """Get statistics for all games."""
    stats = db.query(
        func.count(Score.id).label('total_games'),
        func.max(Score.score).label('highest_score'),
        func.avg(Score.score).label('average_score'),
        func.sum(Score.lines).label('total_lines_cleared')
    ).first()
    
    return LeaderboardStats(
        total_games=stats.total_games or 0,
        highest_score=stats.highest_score or 0,
        average_score=round(float(stats.average_score or 0), 2),
        total_lines_cleared=stats.total_lines_cleared or 0
    )

