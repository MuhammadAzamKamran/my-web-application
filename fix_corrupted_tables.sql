-- Fix Corrupted Tables Script
-- This will safely drop the corrupted tables and recreate them
-- WARNING: This will DELETE all data in these tables!

USE knowledge_base;

-- Drop corrupted tables (they don't exist in engine anyway)
DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS document_tags;
DROP TABLE IF EXISTS document;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS user;

-- Now recreate them using the schema
-- (The schema.sql file contains the CREATE TABLE statements)

