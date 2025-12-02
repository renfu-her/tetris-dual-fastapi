-- Initialize Tetris Dual Database
-- Run this script to create the database and tables

-- Create database
CREATE DATABASE IF NOT EXISTS `tetris-dual` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Use the database
USE `tetris-dual`;

-- Note: Tables will be automatically created by SQLAlchemy when the FastAPI app starts
-- This is just for reference. The actual table structure is defined in app/models.py

-- The scores table structure (for reference):
/*
CREATE TABLE IF NOT EXISTS scores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    player_name VARCHAR(100) NOT NULL,
    score INT NOT NULL,
    lines INT NOT NULL,
    mode ENUM('1P', '2P') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_score (score DESC),
    INDEX idx_mode (mode),
    INDEX idx_score_mode_created (score DESC, mode, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
*/

-- Verify database creation
SELECT 'Database tetris-dual created successfully!' AS message;
SHOW TABLES;

