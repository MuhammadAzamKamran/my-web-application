-- Fix Tablespace Error Script
-- Run this AFTER you've created the tables with schema.sql

USE knowledge_base;

-- Step 1: Discard the empty tablespaces from newly created tables
ALTER TABLE user DISCARD TABLESPACE;
ALTER TABLE document DISCARD TABLESPACE;
ALTER TABLE comments DISCARD TABLESPACE;
ALTER TABLE tags DISCARD TABLESPACE;
ALTER TABLE document_tags DISCARD TABLESPACE;

-- Step 2: NOW STOP MySQL and copy the .ibd files from backup
-- Copy from: C:\xampp\mysql\data_backup_20251101_152717\knowledge_base\*.ibd
-- To: C:\xampp\mysql\data\knowledge_base\*.ibd

-- Step 3: Start MySQL and run the IMPORT commands below:

-- Step 4: Import the backed-up tablespaces
ALTER TABLE user IMPORT TABLESPACE;
ALTER TABLE document IMPORT TABLESPACE;
ALTER TABLE comments IMPORT TABLESPACE;
ALTER TABLE tags IMPORT TABLESPACE;
ALTER TABLE document_tags IMPORT TABLESPACE;

