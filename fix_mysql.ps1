# MySQL Troubleshooting Script for XAMPP
# Run this script as Administrator

Write-Host "=== MySQL Troubleshooting Script ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Stop MySQL if running
Write-Host "Step 1: Stopping MySQL processes..." -ForegroundColor Yellow
$mysqlProcesses = Get-Process | Where-Object {$_.ProcessName -eq "mysqld"}
if ($mysqlProcesses) {
    $mysqlProcesses | Stop-Process -Force
    Write-Host "MySQL processes stopped." -ForegroundColor Green
    Start-Sleep -Seconds 2
} else {
    Write-Host "No MySQL processes found running." -ForegroundColor Green
}

# Step 2: Check port 3306
Write-Host "`nStep 2: Checking port 3306..." -ForegroundColor Yellow
$portCheck = netstat -ano | findstr :3306
if ($portCheck) {
    Write-Host "WARNING: Port 3306 is still in use!" -ForegroundColor Red
    Write-Host $portCheck
} else {
    Write-Host "Port 3306 is free." -ForegroundColor Green
}

# Step 3: Fix Aria log issue
Write-Host "`nStep 3: Checking Aria log files..." -ForegroundColor Yellow
$ariaLogControl = "C:\xampp\mysql\data\aria_log_control"
if (Test-Path $ariaLogControl) {
    $fileSize = (Get-Item $ariaLogControl).Length
    if ($fileSize -lt 52) {
        Write-Host "Aria log control file seems corrupted. Backing up and will regenerate..." -ForegroundColor Yellow
        Copy-Item $ariaLogControl "$ariaLogControl.backup" -ErrorAction SilentlyContinue
        Remove-Item $ariaLogControl -Force
        Write-Host "Aria log control file removed. MySQL will recreate it on startup." -ForegroundColor Green
    } else {
        Write-Host "Aria log control file looks OK." -ForegroundColor Green
    }
} else {
    Write-Host "Aria log control file not found (will be created on startup)." -ForegroundColor Yellow
}

# Step 4: Verify my.ini configuration
Write-Host "`nStep 4: Checking my.ini configuration..." -ForegroundColor Yellow
$myIniPath = "C:\xampp\mysql\bin\my.ini"
if (Test-Path $myIniPath) {
    $content = Get-Content $myIniPath -Raw
    if ($content -match 'bind-address="127\.0\.0\.1"') {
        Write-Host "bind-address is correctly set to 127.0.0.1" -ForegroundColor Green
    } else {
        Write-Host "WARNING: bind-address might not be set correctly!" -ForegroundColor Red
    }
} else {
    Write-Host "ERROR: my.ini not found at $myIniPath" -ForegroundColor Red
}

# Step 5: Check data directory permissions
Write-Host "`nStep 5: Checking data directory..." -ForegroundColor Yellow
$dataDir = "C:\xampp\mysql\data"
if (Test-Path $dataDir) {
    $access = Test-Path $dataDir -PathType Container
    if ($access) {
        Write-Host "Data directory exists and is accessible." -ForegroundColor Green
    }
} else {
    Write-Host "ERROR: Data directory not found!" -ForegroundColor Red
}

# Step 6: Verify MySQL executable
Write-Host "`nStep 6: Checking MySQL executable..." -ForegroundColor Yellow
$mysqldPath = "C:\xampp\mysql\bin\mysqld.exe"
if (Test-Path $mysqldPath) {
    Write-Host "MySQL executable found." -ForegroundColor Green
} else {
    Write-Host "ERROR: MySQL executable not found!" -ForegroundColor Red
}

Write-Host "`n=== Troubleshooting Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Open XAMPP Control Panel as Administrator" -ForegroundColor White
Write-Host "2. Try starting MySQL" -ForegroundColor White
Write-Host "3. If it still fails, check: C:\xampp\mysql\data\mysql_error.log" -ForegroundColor White
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

