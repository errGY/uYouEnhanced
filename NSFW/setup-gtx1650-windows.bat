@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ============================================================
::  Wan2GP + Cursor MCP — установка в C:\Users\Owner\Videos\NSFW
::  GTX 1650 4GB + 32GB RAM
:: ============================================================

set "INSTALL_DIR=C:\Users\Owner\Videos\NSFW\Wan2GP"
set "CURSOR_MCP=C:\Users\Owner\.cursor\mcp.json"
set "BASE_DIR=C:\Users\Owner\Videos\NSFW"

echo ============================================================
echo   Wan2GP Setup
echo   Install path: %INSTALL_DIR%
echo ============================================================
echo.

if not exist "%BASE_DIR%" mkdir "%BASE_DIR%"

:: --- Check GPU ---
where nvidia-smi >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] nvidia-smi not found. Install NVIDIA drivers first!
    echo     https://www.nvidia.com/Download/index.aspx
    pause
    exit /b 1
)
echo [+] GPU:
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
echo.

:: --- Clone Wan2GP ---
if not exist "%INSTALL_DIR%\.git" (
    echo [*] Cloning Wan2GP into %INSTALL_DIR%...
    git clone https://github.com/deepbeepmeep/Wan2GP.git "%INSTALL_DIR%"
)
cd /d "%INSTALL_DIR%"

:: --- Auto install ---
if not exist "%INSTALL_DIR%\env_venv\Scripts\python.exe" (
    echo [*] Installing dependencies - 15-40 minutes, please wait...
    echo 1| python setup.py install --env venv --auto
    if %errorlevel% neq 0 (
        echo [!] Auto install failed. Try: scripts\install.bat
        pause
        exit /b 1
    )
)

set "PYTHON=%INSTALL_DIR%\env_venv\Scripts\python.exe"
echo [+] Python: %PYTHON%

:: --- GTX 1650 low-VRAM config ---
echo [*] Writing wgp_config.json (profile 5)...
(
echo {
echo     "attention_mode": "sdpa",
echo     "compile": "",
echo     "video_profile": 5,
echo     "image_profile": 5,
echo     "audio_profile": 5
echo }
) > "%INSTALL_DIR%\wgp_config.json"

:: --- Folders ---
if not exist "%INSTALL_DIR%\outputs" mkdir "%INSTALL_DIR%\outputs"
if not exist "%INSTALL_DIR%\models\loras" mkdir "%INSTALL_DIR%\models\loras"
if not exist "%BASE_DIR%\generated" mkdir "%BASE_DIR%\generated"

:: --- Download model 1.3B ---
echo [*] Downloading Wan 2.1 T2V 1.3B...
"%PYTHON%" -m pip install -q huggingface_hub
"%PYTHON%" -c "from huggingface_hub import hf_hub_download; import os; dest=os.path.join(r'%INSTALL_DIR%','ckpts'); os.makedirs(dest,exist_ok=True); p=hf_hub_download('DeepBeepMeep/Wan2.1', 'wan2.1_text2video_1.3B_mbf16.safetensors', local_dir=dest); print('OK:', p)"

:: --- Cursor MCP ---
echo [*] Writing Cursor MCP config...
if not exist "C:\Users\Owner\.cursor" mkdir "C:\Users\Owner\.cursor"
"%PYTHON%" -c "import json,os; d={'mcpServers':{'wangp':{'command':r'%PYTHON%','args':[r'%INSTALL_DIR%\wgp.py','--mcp','--mcp-transport','stdio','--profile','5','--attention','sdpa','--config',r'%INSTALL_DIR%','--output-dir',r'%BASE_DIR%\generated'],'cwd':r'%INSTALL_DIR%'}}}; json.dump(d,open(r'%CURSOR_MCP%','w'),indent=2); print('MCP:', r'%CURSOR_MCP%')"

:: --- README ---
(
echo Wan2GP Video Generation
echo =======================
echo Install:  %INSTALL_DIR%
echo Videos:   %BASE_DIR%\generated
echo LoRAs:    %INSTALL_DIR%\models\loras
echo MCP:      %CURSOR_MCP%
echo.
echo Cursor: Reload Window -^> Settings -^> MCP -^> wangp green
echo Prompt:  Сгенерируй видео: your prompt, 480p, 25 frames
) > "%BASE_DIR%\README.txt"

echo.
echo ============================================================
echo   DONE!
echo ============================================================
echo   Wan2GP:   %INSTALL_DIR%
echo   Videos:   %BASE_DIR%\generated
echo   LoRAs:    %INSTALL_DIR%\models\loras  ^(NSFW с Civitai^)
echo   MCP:      %CURSOR_MCP%
echo.
echo   1. Reload Cursor ^(Ctrl+Shift+P -^> Reload Window^)
echo   2. Settings -^> MCP -^> wangp green
echo   3. Close Chrome GPU: %INSTALL_DIR%\scripts\start-chrome-no-gpu.bat
echo.
pause
