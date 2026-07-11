@echo off
:: Run as Administrator if normal delete fails
chcp 65001 >nul
title FIX - Delete broken Wan2GP

echo.
echo  Removing broken install...
echo  C:\Users\Owner\Videos\NSFW\Wan2GP
echo.

rmdir /s /q "C:\Users\Owner\Videos\NSFW\Wan2GP" 2>nul
rmdir /s /q "C:\Users\Owner\Videos\NSFW\_wan2gp_tmp" 2>nul
timeout /t 2 /nobreak >nul

if exist "C:\Users\Owner\Videos\NSFW\Wan2GP" (
    echo.
    echo  [!] Folder still exists!
    echo.
    echo  Try manually:
    echo    1. Open Explorer
    echo    2. Go to C:\Users\Owner\Videos\NSFW
    echo    3. Delete folder Wan2GP
    echo    4. Run INSTALL-NSFW.bat again
    echo.
    echo  Or right-click this file -^> Run as administrator
    echo.
) else (
    echo  [OK] Folder deleted!
    echo  Now run INSTALL-NSFW.bat
    echo.
)

pause
