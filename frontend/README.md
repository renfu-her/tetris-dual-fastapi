<div align="center">
<img width="1200" height="475" alt="GHBanner" src="https://github.com/user-attachments/assets/0aa67016-6eaf-458a-adb2-6e31a0763ed6" />
</div>

# Run and deploy your AI Studio app

This contains everything you need to run your app locally.

View your app in AI Studio: https://ai.studio/apps/drive/1yTz1KcCUAq_ogpgNnZyhM044m_9_1D71

## Run Locally

**Prerequisites:**  Node.js

1. Install dependencies:
   ```bash
   npm install
   # or
   pnpm install
   ```

2. Configure environment variables:
   - Copy `env.template` to `.env`:
     ```bash
     cp env.template .env
     ```
   - Edit `.env` and set the backend API URL:
     - For production: `VITE_API_BASE_URL=https://tetris-game.ai-tracks.com/api`
     - For local development: `VITE_API_BASE_URL=http://localhost:8000/api`
   - (Optional) Set `GEMINI_API_KEY` if using Gemini AI features

3. Run the app:
   ```bash
   npm run dev
   # or
   pnpm dev
   ```

The app will be available at http://localhost:3000
