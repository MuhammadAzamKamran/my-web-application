@echo off
cd /D C:\xampp
echo Starting MySQL manually...
echo This window must stay open while MySQL is running
echo To stop MySQL, press Ctrl+C in this window
echo.
mysql\bin\mysqld --defaults-file=mysql\bin\my.ini --standalone

