import { LeaderboardEntry } from '../types';

// API base URL - change this if backend runs on different port
const API_BASE_URL = 'https://tetris-game.ai-tracks.com/api';

// Fallback to localStorage for offline mode
const STORAGE_KEY = 'tetris_duel_leaderboard';
const USE_API = true; // Set to false to use localStorage only

export const getLeaderboard = async (): Promise<LeaderboardEntry[]> => {
  if (!USE_API) {
    return getLeaderboardFromStorage();
  }

  try {
    const response = await fetch(`${API_BASE_URL}/leaderboard?mode=all&limit=10`);
    if (!response.ok) {
      throw new Error('Failed to fetch leaderboard');
    }
    const data = await response.json();
    
    // Transform API response to match LeaderboardEntry format
    return data.map((item: any) => ({
      name: item.player_name,
      score: item.score,
      mode: item.mode,
      date: new Date(item.created_at).toLocaleDateString(),
    }));
  } catch (e) {
    console.error("Failed to fetch leaderboard from API, using localStorage fallback", e);
    return getLeaderboardFromStorage();
  }
};

// Store game state temporarily for 2P mode
let pendingGame: {
  player1?: { name: string; score: number; lines: number };
  player2?: { name: string; score: number; lines: number };
  winner?: number;
} = {};

export const saveScore = async (
  name: string, 
  score: number, 
  mode: '1P' | '2P', 
  lines: number = 0,
  isPlayer2: boolean = false,
  isWinner: boolean = false
): Promise<LeaderboardEntry[]> => {
  if (!USE_API) {
    return saveScoreToStorage(name, score, mode);
  }

  try {
    if (mode === '1P') {
      // For 1P mode, save immediately
      const response = await fetch(`${API_BASE_URL}/games`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          mode: '1P',
          player1: {
            name: name,
            score: score,
            lines: lines,
          },
          player2: null,
          winner: null,
        }),
      });

      if (!response.ok) {
        throw new Error('Failed to save game');
      }
    } else {
      // For 2P mode, collect both players' data
      if (!isPlayer2) {
        // First player (Player 1)
        pendingGame.player1 = { name, score, lines };
        if (isWinner) pendingGame.winner = 1;
        console.log('Saved Player 1 data:', pendingGame.player1);
      } else {
        // Second player (Player 2)
        pendingGame.player2 = { name, score, lines };
        if (isWinner && !pendingGame.winner) pendingGame.winner = 2;
        console.log('Saved Player 2 data:', pendingGame.player2);
        
        // Both players recorded, save the game
        if (pendingGame.player1 && pendingGame.player2) {
          console.log('Submitting game:', pendingGame);
          const response = await fetch(`${API_BASE_URL}/games`, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({
              mode: '2P',
              player1: pendingGame.player1,
              player2: pendingGame.player2,
              winner: pendingGame.winner || null,
            }),
          });

          if (!response.ok) {
            const errorData = await response.text();
            console.error('Failed to save game:', response.status, errorData);
            throw new Error('Failed to save game');
          }
          
          console.log('Game saved successfully!');
          // Clear pending game
          pendingGame = {};
        } else {
          console.warn('Missing player data:', { player1: pendingGame.player1, player2: pendingGame.player2 });
        }
      }
    }

    // After saving, fetch updated leaderboard
    return await getLeaderboard();
  } catch (e) {
    console.error("Failed to save game to API, using localStorage fallback", e);
    return saveScoreToStorage(name, score, mode);
  }
};

// LocalStorage fallback functions
function getLeaderboardFromStorage(): LeaderboardEntry[] {
  try {
    const data = localStorage.getItem(STORAGE_KEY);
    return data ? JSON.parse(data) : [];
  } catch (e) {
    console.error("Failed to parse leaderboard", e);
    return [];
  }
}

function saveScoreToStorage(name: string, score: number, mode: '1P' | '2P'): LeaderboardEntry[] {
  const current = getLeaderboardFromStorage();
  const entry: LeaderboardEntry = {
    name,
    score,
    mode,
    date: new Date().toLocaleDateString(),
  };
  
  const updated = [...current, entry]
    .sort((a, b) => b.score - a.score)
    .slice(0, 10); // Keep top 10

  localStorage.setItem(STORAGE_KEY, JSON.stringify(updated));
  return updated;
}