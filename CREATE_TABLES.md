# Creating Database Tables

## Step 1: Create the Tables

You have two options to create the tables:

### Option A: Using phpMyAdmin (Easier)

1. Open phpMyAdmin in your browser (http://localhost/phpmyadmin)
2. Click on `knowledge_base` database in the left sidebar
3. Click the "SQL" tab at the top
4. Copy and paste the entire contents of `schema.sql` file
5. Click "Go" or press Ctrl+Enter
6. You should see success messages for all 5 tables

### Option B: Using MySQL Command Line

1. Open Command Prompt
2. Run:
   ```
   cd "C:\Users\mkwaq\OneDrive\Documents\Project files"
   C:\xampp\mysql\bin\mysql.exe -u root knowledge_base < schema.sql
   ```

## Step 2: Verify Tables Were Created

In phpMyAdmin:
- Refresh the `knowledge_base` database
- You should see these 5 tables:
  - `user`
  - `document`
  - `comments`
  - `tags`
  - `document_tags`

## What Each Table Does

- **user**: Stores user information (email, display name)
- **document**: Stores documents (title, description, file path)
- **comments**: Stores comments on documents
- **tags**: Stores tag names
- **document_tags**: Links documents to tags (many-to-many relationship)

