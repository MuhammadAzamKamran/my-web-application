-- Complete Recovery Script
-- Run this FIRST to drop corrupted tables and recreate them

USE knowledge_base;

-- Drop all corrupted tables (they don't exist in engine anyway, so this is safe)
DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS document_tags;
DROP TABLE IF EXISTS document;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS user;

-- Now run schema.sql to create fresh tables
-- (The CREATE TABLE statements are in schema.sql file)

