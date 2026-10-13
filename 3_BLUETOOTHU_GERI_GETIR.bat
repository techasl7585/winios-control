@echo off
chcp 65001 >nul
cd /d "%~dp0"

echo CommunicatePars - Intel Bluetooth surucusunu geri yukleme
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Restore-IntelBluetooth.ps1"
echo.
pause

