@echo off
chcp 65001 >nul
cd /d "%~dp0"

echo CommunicatePars - Intel Bluetooth surucu yedegi
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Backup-IntelBluetooth.ps1"
echo.
pause

