import { LeaderboardEntry } from '../types';

// API base URL - change this if backend runs on different port
const API_BASE_URL = 'http://localhost:8000/api';

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

export const saveScore = async (name: string, score: number, mode: '1P' | '2P', lines: number = 0): Promise<LeaderboardEntry[]> => {
  if (!USE_API) {
    return saveScoreToStorage(name, score, mode);
  }

  try {
    const response = await fetch(`${API_BASE_URL}/scores`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        player_name: name,
        score: score,
        lines: lines,
        mode: mode,
      }),
    });

    if (!response.ok) {
      throw new Error('Failed to save score');
    }

    // After saving, fetch updated leaderboard
    return await getLeaderboard();
  } catch (e) {
    console.error("Failed to save score to API, using localStorage fallback", e);
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