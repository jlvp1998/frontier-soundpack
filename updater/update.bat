@echo off
rem Updates the Frontier soundpack. You can run this with MUSHclient closed,
rem or type spupdate in the game.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0update.ps1" -Mode update
echo.
pause
