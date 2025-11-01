# Final Recovery Steps - Fix "Tablespace Exists" Error

## The Problem
You dropped the tables, but the `.ibd` files are still in the data directory. When MySQL tries to create new tables, it sees old `.ibd` files and gets confused.

## The Solution

### Step 1: Stop MySQL
- Stop MySQL in XAMPP Control Panel
- Or close the START_MYSQL_MANUALLY.bat window
- **Important**: MySQL MUST be stopped to delete .ibd files safely

### Step 2: Delete the Old .ibd Files

**Option A: Using PowerShell Script (Easier)**
1. Run `delete_old_ibd_files.ps1` (right-click → Run with PowerShell)
2. It will check if MySQL is stopped and delete the files

**Option B: Manual Delete**
```powershell
# Make sure MySQL is STOPPED first!
Remove-Item "C:\xampp\mysql\data\knowledge_base\*.ibd" -Force
```

### Step 3: Start MySQL Again

### Step 4: Create Tables with schema.sql
- Open phpMyAdmin
- Click on `knowledge_base` database
- Click "SQL" tab
- Copy and paste the entire contents of `schema.sql`
- Click "Go"
- You should see 5 "Table created successfully" messages

### Step 5: Now Restore Your Data

After tables are created:

1. **Discard the empty tablespaces:**
```sql
USE knowledge_base;

ALTER TABLE `user` DISCARD TABLESPACE;
ALTER TABLE `document` DISCARD TABLESPACE;
ALTER TABLE `comments` DISCARD TABLESPACE;
ALTER TABLE `tags` DISCARD TABLESPACE;
ALTER TABLE `document_tags` DISCARD TABLESPACE;
```

2. **Stop MySQL**

3. **Copy your data files:**
```powershell
Copy-Item "C:\xampp\mysql\data_backup_20251101_152717\knowledge_base\*.ibd" -Destination "C:\xampp\mysql\data\knowledge_base\" -Force
```

4. **Start MySQL**

5. **Import the tablespaces:**
```sql
USE knowledge_base;

ALTER TABLE `user` IMPORT TABLESPACE;
ALTER TABLE `document` IMPORT TABLESPACE;
ALTER TABLE `comments` IMPORT TABLESPACE;
ALTER TABLE `tags` IMPORT TABLESPACE;
ALTER TABLE `document_tags` IMPORT TABLESPACE;
```

6. **Verify your data:**
```sql
SELECT COUNT(*) FROM user;
SELECT COUNT(*) FROM document;
```

Your data should be restored! 🎉

