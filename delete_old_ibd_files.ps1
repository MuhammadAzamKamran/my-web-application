# Delete old .ibd files that are causing the tablespace conflict
# Run this AFTER dropping tables but BEFORE creating new ones

Write-Host "=== Cleaning Up Old Tablespace Files ===" -ForegroundColor Cyan
Write-Host ""

$dataPath = "C:\xampp\mysql\data\knowledge_base"

# Check if MySQL is running
$mysqlRunning = Get-Process | Where-Object {$_.ProcessName -eq "mysqld"}
if ($mysqlRunning) {
    Write-Host "WARNING: MySQL is running!" -ForegroundColor Red
    Write-Host "You MUST stop MySQL first before deleting .ibd files!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please:" -ForegroundColor Yellow
    Write-Host "1. Stop MySQL in XAMPP Control Panel" -ForegroundColor White
    Write-Host "2. Or close START_MYSQL_MANUALLY.bat window" -ForegroundColor White
    Write-Host "3. Then run this script again" -ForegroundColor White
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

if (-not (Test-Path $dataPath)) {
    Write-Host "ERROR: Database directory not found: $dataPath" -ForegroundColor Red
    exit 1
}

Write-Host "Step 1: Finding .ibd files..." -ForegroundColor Yellow
$ibdFiles = Get-ChildItem "$dataPath\*.ibd" -ErrorAction SilentlyContinue

if (-not $ibdFiles) {
    Write-Host "No .ibd files found. You're good to go!" -ForegroundColor Green
    Write-Host "You can now create tables with schema.sql" -ForegroundColor Green
    exit 0
}

Write-Host "Found the following .ibd files:" -ForegroundColor Yellow
$ibdFiles | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor Gray }

Write-Host ""
Write-Host "Step 2: Deleting old .ibd files..." -ForegroundColor Yellow
$ibdFiles | Remove-Item -Force
Write-Host "✓ Deleted all .ibd files" -ForegroundColor Green

Write-Host ""
Write-Host "=== Cleanup Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Start MySQL" -ForegroundColor White
Write-Host "2. Run schema.sql in phpMyAdmin to create tables" -ForegroundColor White
Write-Host "3. Then follow the restore data steps" -ForegroundColor White
Write-Host ""
Read-Host "Press Enter to exit"

