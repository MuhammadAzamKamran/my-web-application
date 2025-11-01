# Correct Recovery Steps (Fixing Tablespace Error)

## The Problem
You have the .ibd data files, but the tables aren't created yet. MySQL is confused because:
- The tablespace (.ibd) files exist
- But the table definitions don't exist in MySQL's catalog

## The Solution - Correct Order

### Step 1: Create the Tables First
In phpMyAdmin SQL tab, run the contents of `schema.sql`:
- This creates all 5 tables (user, document, comments, tags, document_tags)
- These tables will be empty initially

### Step 2: Discard the Empty Tablespaces
In phpMyAdmin SQL tab, run:
```sql
USE knowledge_base;

ALTER TABLE user DISCARD TABLESPACE;
ALTER TABLE document DISCARD TABLESPACE;
ALTER TABLE comments DISCARD TABLESPACE;
ALTER TABLE tags DISCARD TABLESPACE;
ALTER TABLE document_tags DISCARD TABLESPACE;
```

This tells MySQL: "Forget about the empty .ibd files, we're going to replace them"

### Step 3: Stop MySQL
- Stop MySQL in XAMPP Control Panel, or close the batch file

### Step 4: Copy Your Data Files
Copy the .ibd files from backup:
```powershell
Copy-Item "C:\xampp\mysql\data_backup_20251101_152717\knowledge_base\*.ibd" -Destination "C:\xampp\mysql\data\knowledge_base\" -Force
```

This replaces the empty .ibd files with your actual data.

### Step 5: Start MySQL

### Step 6: Import the Tablespaces
In phpMyAdmin SQL tab, run:
```sql
USE knowledge_base;

ALTER TABLE user IMPORT TABLESPACE;
ALTER TABLE document IMPORT TABLESPACE;
ALTER TABLE comments IMPORT TABLESPACE;
ALTER TABLE tags IMPORT TABLESPACE;
ALTER TABLE document_tags IMPORT TABLESPACE;
```

This tells MySQL: "Now use these .ibd files (which contain your data)"

### Step 7: Verify Your Data
```sql
SELECT COUNT(*) FROM user;
SELECT COUNT(*) FROM document;
SELECT * FROM document LIMIT 5;
```

Your data should be back! 🎉

