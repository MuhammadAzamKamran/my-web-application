# MySQL Connection Timeout Fix Guide

## Problem
MySQL shows as "started" in XAMPP but:
- Your Node.js app gets `ETIMEDOUT` errors
- phpMyAdmin loads forever
- Connections timeout

## Root Cause
MySQL is starting but crashing immediately after creating the socket, or not properly binding to the network interface.

## Solution Steps

### Step 1: Complete MySQL Restart (CRITICAL)
1. **Stop MySQL completely:**
   - Open XAMPP Control Panel
   - Click "Stop" on MySQL
   - Wait 10 seconds
   - Check the "Actions" column - if it still shows a PID, MySQL isn't fully stopped

2. **Kill any remaining processes:**
   - Open Task Manager (Ctrl+Shift+Esc)
   - Look for `mysqld.exe` or `mysqld` processes
   - End all MySQL processes

3. **Restart MySQL:**
   - In XAMPP Control Panel, click "Start" on MySQL
   - Wait 15-20 seconds
   - Check if it stays green (not just briefly turning green then red)

### Step 2: Fix Aria Log Issues (If Step 1 doesn't work)
If MySQL still shuts down unexpectedly:

1. **Stop MySQL** (must be stopped first!)

2. **Fix Aria log files:**
   - Navigate to: `C:\xampp\mysql\data\`
   - Delete or rename these files (MySQL will recreate them):
     - `aria_log_control`
     - `aria_log.00000001`
   - **IMPORTANT:** Only do this if MySQL is stopped!

3. **Start MySQL again**

### Step 3: Verify MySQL is Actually Running
After starting MySQL, verify it's truly running:

1. **Check Process:**
   - Open Task Manager
   - Look for `mysqld.exe` process
   - If it disappears, MySQL is crashing

2. **Check Port:**
   - Open Command Prompt as Administrator
   - Run: `netstat -ano | findstr :3306`
   - You should see a line showing `LISTENING` on port 3306
   - If nothing appears, MySQL isn't listening

3. **Check Error Log:**
   - Navigate to: `C:\xampp\mysql\data\mysql_error.log`
   - Scroll to the very bottom
   - Look for any `[ERROR]` messages after the socket creation

### Step 4: Test Connection Manually
Test if MySQL accepts connections:

1. Open Command Prompt
2. Navigate to: `cd C:\xampp\mysql\bin`
3. Run: `mysql.exe -u root -p`
   - Press Enter when asked for password (XAMPP default is empty)
   - If you get a `mysql>` prompt, MySQL is working!
   - Type `exit` to quit

### Step 5: Alternative - Reset MySQL (Last Resort)
If nothing works and you can afford to lose data:

1. **Backup your databases** (if you have important data):
   - Copy `C:\xampp\mysql\data\` to `C:\xampp\mysql\data_backup\`

2. **Stop MySQL completely**

3. **Reinitialize MySQL:**
   - Open Command Prompt as Administrator
   - Run:
     ```
     cd C:\xampp\mysql\bin
     mysqld.exe --initialize-insecure --console
     ```
   - This creates a fresh MySQL installation

4. **Start MySQL in XAMPP**

## Configuration Changes Already Applied

✅ **bind-address** set to `127.0.0.1` (IPv4) instead of IPv6
✅ **Database connection** updated with better timeout handling

## Still Not Working?

1. **Run the troubleshooting script:**
   - Right-click `fix_mysql.ps1`
   - Select "Run with PowerShell"
   - Review the output

2. **Check Windows Event Viewer:**
   - Win+X → Event Viewer
   - Windows Logs → Application
   - Look for MySQL errors around the time you tried to start it

3. **Check for Antivirus Interference:**
   - Temporarily disable Windows Defender or your antivirus
   - Try starting MySQL again
   - If it works, add XAMPP folders to antivirus exclusions

## Your Node.js App Configuration

Make sure you have a `.env` file in your project root with:
```
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=
DB_NAME=your_database_name
```

If you don't have a `.env` file, the updated `db.js` will use defaults (localhost, root, no password).

