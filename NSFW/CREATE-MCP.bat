@echo off
chcp 65001 >nul
title Create Cursor MCP config for wangp

set "INSTALL_DIR=C:\Users\Owner\Videos\NSFW\Wan2GP"
set "OUT_DIR=C:\Users\Owner\Videos\NSFW\generated"
set "PYTHON=%INSTALL_DIR%\env_venv\Scripts\python.exe"
set "MCP_FILE=C:\Users\Owner\.cursor\mcp.json"

echo.
echo  Creating: %MCP_FILE%
echo.

if not exist "%PYTHON%" (
    echo [!] Python not found:
    echo     %PYTHON%
    echo     Run INSTALL-NSFW.bat first.
    pause & exit /b 1
)

if not exist "%INSTALL_DIR%\wgp.py" (
    echo [!] wgp.py not found. Wan2GP not installed?
    pause & exit /b 1
)

mkdir "C:\Users\Owner\.cursor" 2>nul

"%PYTHON%" -c "import json; d={'mcpServers':{'wangp':{'command':r'%PYTHON%','args':[r'%INSTALL_DIR%\wgp.py','--mcp','--mcp-transport','stdio','--profile','5','--attention','sdpa','--config',r'%INSTALL_DIR%','--output-dir',r'%OUT_DIR%'],'cwd':r'%INSTALL_DIR%'}}}; json.dump(d, open(r'%MCP_FILE%','w'), indent=2); print('OK')"

if exist "%MCP_FILE%" (
    echo.
    echo  [OK] mcp.json created!
    echo.
    echo  NEXT:
    echo    1. Open Cursor
    echo    2. Ctrl+Shift+P -^> Reload Window
    echo    3. Settings -^> Customize -^> MCP
    echo    4. wangp should appear GREEN
    echo.
    type "%MCP_FILE%"
) else (
    echo [!] Failed to create mcp.json
)

echo.
pause
