# Restore Data from Backup Script
# This will restore your knowledge_base tables from the backup

Write-Host "=== Data Restoration Script ===" -ForegroundColor Cyan
Write-Host ""

$backupPath = "C:\xampp\mysql\data_backup_20251101_152717\knowledge_base"
$targetPath = "C:\xampp\mysql\data\knowledge_base"

# Check if backup exists
if (-not (Test-Path $backupPath)) {
    Write-Host "ERROR: Backup path not found!" -ForegroundColor Red
    Write-Host "Expected: $backupPath" -ForegroundColor Yellow
    exit 1
}

Write-Host "Step 1: Checking MySQL processes..." -ForegroundColor Yellow
$mysqlProcesses = Get-Process | Where-Object {$_.ProcessName -eq "mysqld"}
if ($mysqlProcesses) {
    Write-Host "WARNING: MySQL is running!" -ForegroundColor Red
    Write-Host "Please STOP MySQL first before running this script." -ForegroundColor Yellow
    Write-Host "You can stop it in XAMPP Control Panel or run:" -ForegroundColor Yellow
    Write-Host "  Get-Process | Where-Object {`$_.ProcessName -eq 'mysqld'} | Stop-Process -Force" -ForegroundColor Gray
    Write-Host ""
    $continue = Read-Host "Continue anyway? (y/N)"
    if ($continue -ne "y" -and $continue -ne "Y") {
        exit 0
    }
    Write-Host "Stopping MySQL..." -ForegroundColor Yellow
    $mysqlProcesses | Stop-Process -Force
    Start-Sleep -Seconds 3
}

# Ensure target directory exists
if (-not (Test-Path $targetPath)) {
    Write-Host "Creating target directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
}

Write-Host "`nStep 2: Copying table definition files (.frm)..." -ForegroundColor Yellow
Copy-Item "$backupPath\*.frm" -Destination $targetPath -Force -ErrorAction SilentlyContinue
Write-Host "✓ Table definitions copied" -ForegroundColor Green

Write-Host "`nStep 3: Copying data files (.ibd)..." -ForegroundColor Yellow
Copy-Item "$backupPath\*.ibd" -Destination $targetPath -Force
Write-Host "✓ Data files copied" -ForegroundColor Green

Write-Host "`nStep 4: Copying database options..." -ForegroundColor Yellow
if (Test-Path "$backupPath\db.opt") {
    Copy-Item "$backupPath\db.opt" -Destination $targetPath -Force
    Write-Host "✓ Database options copied" -ForegroundColor Green
}

Write-Host "`n=== Restoration Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Start MySQL in XAMPP or run START_MYSQL_MANUALLY.bat" -ForegroundColor White
Write-Host "2. Verify data in phpMyAdmin" -ForegroundColor White
Write-Host "3. If tables still show errors, you may need to run:" -ForegroundColor White
Write-Host "   mysql -u root knowledge_base -e 'FLUSH TABLES;'" -ForegroundColor Gray
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

