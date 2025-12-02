# Change Log

## 2024-12-02 - FastAPI Backend Implementation

### Backend API Created

建立完整的 FastAPI backend 系統，提供俄羅斯方塊遊戲的分數記錄和排行榜功能。

#### New Backend Files

**Project Structure:**
- `backend/pyproject.toml` - uv package manager configuration
- `backend/.env.example` - Environment variables template
- `backend/.gitignore` - Git ignore rules
- `backend/README.md` - Backend documentation

**Application Files:**
- `backend/app/__init__.py` - Application package
- `backend/app/main.py` - FastAPI application with CORS configuration
- `backend/app/database.py` - MySQL database connection and session management
- `backend/app/models.py` - SQLAlchemy ORM models (Score table)
- `backend/app/schemas.py` - Pydantic schemas for validation
- `backend/app/crud.py` - Database CRUD operations

**API Routers:**
- `backend/app/routers/__init__.py` - Routers package
- `backend/app/routers/scores.py` - Score saving endpoint (POST /api/scores)
- `backend/app/routers/leaderboard.py` - Leaderboard endpoints (GET /api/leaderboard, GET /api/leaderboard/stats)

#### Database Schema

**scores table:**
- `id` (INT, PRIMARY KEY, AUTO_INCREMENT)
- `player_name` (VARCHAR(100))
- `score` (INT, indexed)
- `lines` (INT)
- `mode` (ENUM: '1P', '2P', indexed)
- `created_at` (TIMESTAMP)
- Composite index: (score, mode, created_at)

#### API Endpoints

1. **POST /api/scores** - Save game score
   - Request: `{ player_name, score, lines, mode }`
   - Response: Created score record with timestamp

2. **GET /api/leaderboard** - Get leaderboard
   - Query params: `mode` (1P/2P/all), `limit` (1-100)
   - Response: Sorted list of top scores

3. **GET /api/leaderboard/stats** - Get statistics
   - Response: Total games, highest score, average score, total lines cleared

4. **GET /** - API health check
5. **GET /health** - Service health status

#### Frontend Integration

**Modified Files:**
- `frontend/services/leaderboardService.ts`
  - Changed from localStorage to API calls
  - Added async/await for API requests
  - Kept localStorage as fallback for offline mode
  - Added `USE_API` flag to toggle between API and localStorage

- `frontend/components/Leaderboard.tsx`
  - Updated to use async getLeaderboard()
  
- `frontend/App.tsx`
  - Updated handleEndGame to await saveScore()

#### Technical Stack

- **FastAPI** - Modern Python web framework
- **SQLAlchemy** - ORM for database operations
- **MySQL** - Database (root user, no password, database: tetris-dual)
- **uv** - Fast Python package manager
- **Pydantic** - Data validation
- **CORS** - Configured for localhost:5173

#### Features

- ✅ 1-2 player game support
- ✅ Score recording with player name, score, lines, and mode
- ✅ Leaderboard with mode filtering (1P, 2P, or all)
- ✅ Game statistics endpoint
- ✅ CORS enabled for frontend integration
- ✅ Automatic database table creation
- ✅ API documentation (Swagger UI at /docs)
- ✅ Fallback to localStorage if API unavailable

#### Setup Instructions

1. Install backend dependencies:
   ```bash
   cd backend
   uv sync
   ```

2. Create MySQL database:
   ```sql
   CREATE DATABASE `tetris-dual` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```

3. Start backend server:
   ```bash
   uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

4. Access API documentation: http://localhost:8000/docs

---

