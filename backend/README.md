# Tetris Dual - Backend API

FastAPI backend for the Tetris Dual game, providing score recording and leaderboard functionality.

## Tech Stack

- **FastAPI** - Modern web framework for building APIs
- **SQLAlchemy** - ORM for database operations
- **MySQL** - Database for storing scores
- **uv** - Fast Python package manager
- **Pydantic** - Data validation

## Setup

### Prerequisites

- Python 3.11+
- MySQL server running
- uv package manager installed

### Installation

1. Install dependencies with uv:
```bash
cd backend
uv sync
```

2. Create MySQL database:
```sql
CREATE DATABASE `tetris-dual` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

3. Copy environment variables:
```bash
cp .env.example .env
```

4. Update `.env` with your database credentials if needed

### Running the Server

#### Development Mode

```bash
uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Or use the start script:
```bash
# Linux/Mac
./start.sh

# Windows
start.bat
```

#### Production Mode (with Gunicorn)

```bash
# Linux/Mac
./start-prod.sh

# Windows
start-prod.bat

# Manual
uv run gunicorn app.main:app --config gunicorn.conf.py --worker-class uvicorn.workers.UvicornWorker
```

The API will be available at `http://localhost:8000`

API documentation (Swagger UI): `http://localhost:8000/docs`

## API Endpoints

### POST `/api/scores`
Save a game score

**Request Body:**
```json
{
  "player_name": "Player1",
  "score": 1500,
  "lines": 15,
  "mode": "1P"
}
```

**Response:**
```json
{
  "id": 1,
  "player_name": "Player1",
  "score": 1500,
  "lines": 15,
  "mode": "1P",
  "created_at": "2024-12-02T10:30:00"
}
```

### GET `/api/leaderboard`
Get leaderboard rankings

**Query Parameters:**
- `mode` (optional): "1P", "2P", or "all" (default: "all")
- `limit` (optional): Number of results (default: 10)

**Response:**
```json
[
  {
    "id": 1,
    "player_name": "Player1",
    "score": 1500,
    "lines": 15,
    "mode": "1P",
    "created_at": "2024-12-02T10:30:00"
  }
]
```

### GET `/api/leaderboard/stats`
Get game statistics

**Response:**
```json
{
  "total_games": 100,
  "highest_score": 5000,
  "average_score": 1250.5,
  "total_lines_cleared": 1500
}
```

## Production Deployment

For production deployment with Gunicorn, see [PRODUCTION.md](PRODUCTION.md) for:
- Gunicorn configuration
- Systemd service setup
- Docker deployment
- Nginx reverse proxy
- Performance optimization
- Security best practices

## Development

### Project Structure

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py              # FastAPI application
│   ├── database.py          # MySQL connection
│   ├── models.py            # SQLAlchemy models
│   ├── schemas.py           # Pydantic schemas
│   ├── crud.py              # Database operations
│   └── routers/
│       ├── __init__.py
│       ├── scores.py        # Score endpoints
│       └── leaderboard.py   # Leaderboard endpoints
├── pyproject.toml           # uv project config
├── .env.example             # Environment variables template
└── README.md
```

## License

MIT

