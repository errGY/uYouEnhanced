@echo off
chcp 65001 >nul
title NSFW - Clean reinstall

echo Deleting broken install...
rmdir /s /q "C:\Users\Owner\Videos\NSFW\Wan2GP" 2>nul
timeout /t 2 /nobreak >nul
echo Done. Now run INSTALL-NSFW.bat
pause
