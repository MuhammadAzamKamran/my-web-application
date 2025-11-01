# Complete Data Recovery Steps

## Process Overview

1. **Drop corrupted tables** (they're broken anyway)
2. **Create fresh tables** using schema.sql
3. **Restore your data** from backup

## Step-by-Step Instructions

### Step 1: Stop MySQL
- Stop MySQL in XAMPP Control Panel, or
- Close the START_MYSQL_MANUALLY.bat window if you're using it

### Step 2: Drop Corrupted Tables and Create Fresh Ones

**Option A: Using phpMyAdmin (Easier)**
1. Open phpMyAdmin (http://localhost/phpmyadmin)
2. Click on `knowledge_base` database
3. Click "SQL" tab
4. Copy and paste this:

```sql
USE knowledge_base;

DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS document_tags;
DROP TABLE IF EXISTS document;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS user;
```

5. Click "Go"
6. Now copy and paste the entire contents of `schema.sql`
7. Click "Go" again
8. You should see 5 "Table created successfully" messages

**Option B: Using Command Line**
```powershell
cd "C:\Users\mkwaq\OneDrive\Documents\Project files"
C:\xampp\mysql\bin\mysql.exe -u root knowledge_base < RECOVER_AND_RESTORE.sql
C:\xampp\mysql\bin\mysql.exe -u root knowledge_base < schema.sql
```

### Step 3: Restore Your Data Files

Now copy the data files from backup:

```powershell
# Make sure MySQL is STOPPED first!
Copy-Item "C:\xampp\mysql\data_backup_20251101_152717\knowledge_base\*.ibd" -Destination "C:\xampp\mysql\data\knowledge_base\" -Force
```

### Step 4: Import the Tablespaces (Important!)

Start MySQL, then run in MySQL command line or phpMyAdmin SQL tab:

```sql
USE knowledge_base;

ALTER TABLE user DISCARD TABLESPACE;
ALTER TABLE document DISCARD TABLESPACE;
ALTER TABLE comments DISCARD TABLESPACE;
ALTER TABLE tags DISCARD TABLESPACE;
ALTER TABLE document_tags DISCARD TABLESPACE;

-- Now stop MySQL again, copy the .ibd files, then start MySQL

ALTER TABLE user IMPORT TABLESPACE;
ALTER TABLE document IMPORT TABLESPACE;
ALTER TABLE comments IMPORT TABLESPACE;
ALTER TABLE tags IMPORT TABLESPACE;
ALTER TABLE document_tags IMPORT TABLESPACE;
```

## OR: Simpler Method (May Work)

After Step 2 (creating tables with schema.sql):
1. Stop MySQL
2. Copy ALL files from backup:
   ```powershell
   Copy-Item "C:\xampp\mysql\data_backup_20251101_152717\knowledge_base\*" -Destination "C:\xampp\mysql\data\knowledge_base\" -Force
   ```
3. Start MySQL
4. Check if data is there

This simpler method might work if the table structure matches.

