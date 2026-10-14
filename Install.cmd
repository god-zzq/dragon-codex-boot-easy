@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\setup.ps1" -Action Install
if errorlevel 1 (
 echo Installation failed. See the message above.
 pause
 exit /b 1
)
echo Installed. You can close this window.
timeout /t 3 >nul
