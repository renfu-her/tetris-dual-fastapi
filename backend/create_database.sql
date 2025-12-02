-- Create Tetris Dual Database
-- Run this with: mysql -u root < create_database.sql

DROP DATABASE IF EXISTS `tetris-dual`;
CREATE DATABASE `tetris-dual` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Show success message
SELECT 'Database created successfully!' AS Status;
SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'tetris-dual';

