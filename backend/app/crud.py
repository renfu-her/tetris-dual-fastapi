"""CRUD operations for database models."""
from sqlalchemy.orm import Session
from sqlalchemy import func, desc, case, or_
from app.models import Game, GameMode
from app.schemas import GameCreate, LeaderboardStats, LeaderboardEntry
from typing import List, Optional


def create_game(db: Session, game_data: GameCreate) -> Game:
    """Create a new game record."""
    db_game = Game(
        mode=GameMode(game_data.mode),
        player1_name=game_data.player1.name,
        player1_score=game_data.player1.score,
        player1_lines=game_data.player1.lines,
        player2_name=game_data.player2.name if game_data.player2 else None,
        player2_score=game_data.player2.score if game_data.player2 else None,
        player2_lines=game_data.player2.lines if game_data.player2 else None,
        winner=game_data.winner
    )
    db.add(db_game)
    db.commit()
    db.refresh(db_game)
    return db_game


def get_leaderboard(
    db: Session, 
    mode: Optional[str] = None, 
    limit: int = 10
) -> List[LeaderboardEntry]:
    """
    Get leaderboard with optional mode filter.
    Returns flattened list of player performances.
    """
    games = db.query(Game)
    
    # Apply mode filter if specified
    if mode and mode != "all":
        try:
            game_mode = GameMode(mode)
            games = games.filter(Game.mode == game_mode)
        except ValueError:
            return []
    
    games = games.order_by(desc(Game.created_at)).all()
    
    # Flatten games into individual player entries
    entries = []
    for game in games:
        # Add player 1
        entries.append(LeaderboardEntry(
            game_id=game.id,
            player_name=game.player1_name,
            score=game.player1_score,
            lines=game.player1_lines,
            mode=game.mode.value,
            is_winner=game.winner == 1 if game.winner else None,
            created_at=game.created_at
        ))
        
        # Add player 2 if exists
        if game.player2_name:
            entries.append(LeaderboardEntry(
                game_id=game.id,
                player_name=game.player2_name,
                score=game.player2_score,
                lines=game.player2_lines,
                mode=game.mode.value,
                is_winner=game.winner == 2 if game.winner else None,
                created_at=game.created_at
            ))
    
    # Sort by score descending and limit
    entries.sort(key=lambda x: x.score, reverse=True)
    return entries[:limit]


def get_leaderboard_stats(db: Session) -> LeaderboardStats:
    """Get statistics for all games."""
    total_games = db.query(func.count(Game.id)).scalar() or 0
    
    total_1p = db.query(func.count(Game.id)).filter(Game.mode == GameMode.ONE_PLAYER).scalar() or 0
    total_2p = db.query(func.count(Game.id)).filter(Game.mode == GameMode.TWO_PLAYER).scalar() or 0
    
    # Get max score from both player1 and player2
    max_p1 = db.query(func.max(Game.player1_score)).scalar() or 0
    max_p2 = db.query(func.max(Game.player2_score)).scalar() or 0
    highest_score = max(max_p1, max_p2)
    
    # Calculate average score (including both players)
    avg_stats = db.query(
        func.avg(Game.player1_score).label('avg_p1'),
        func.count(Game.player2_score).label('p2_count'),
        func.sum(case((Game.player2_score.isnot(None), Game.player2_score), else_=0)).label('sum_p2')
    ).first()
    
    if avg_stats and avg_stats.avg_p1:
        total_score = float(avg_stats.avg_p1) * total_games
        if avg_stats.p2_count and avg_stats.sum_p2:
            total_score += float(avg_stats.sum_p2)
        total_players = total_games + (avg_stats.p2_count or 0)
        average_score = total_score / total_players if total_players > 0 else 0
    else:
        average_score = 0
    
    # Calculate total lines
    lines_stats = db.query(
        func.sum(Game.player1_lines).label('p1_lines'),
        func.sum(Game.player2_lines).label('p2_lines')
    ).first()
    
    total_lines = (lines_stats.p1_lines or 0) + (lines_stats.p2_lines or 0)
    
    return LeaderboardStats(
        total_games=total_games,
        total_1p_games=total_1p,
        total_2p_games=total_2p,
        highest_score=highest_score,
        average_score=round(float(average_score), 2),
        total_lines_cleared=total_lines
    )

