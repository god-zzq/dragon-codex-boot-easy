@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\setup.ps1" -Action Uninstall
if errorlevel 1 (echo Uninstall failed. See the message above.)
pause
