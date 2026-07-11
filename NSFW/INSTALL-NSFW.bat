@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title NSFW Video Setup - GTX 1650

:: ================================================================
::  Wan2GP + Cursor MCP — C:\Users\Owner\Videos\NSFW
::  GTX 1650 4GB + 32GB RAM
:: ================================================================

set "BASE_DIR=C:\Users\Owner\Videos\NSFW"
set "INSTALL_DIR=%BASE_DIR%\Wan2GP"
set "OUT_DIR=%BASE_DIR%\generated"
set "LORA_DIR=%INSTALL_DIR%\models\loras"
set "CURSOR_MCP=C:\Users\Owner\.cursor\mcp.json"

echo.
echo  ============================================================
echo    NSFW Video Generator - Wan2GP Install
echo    Path: %BASE_DIR%
echo  ============================================================
echo.

mkdir "%BASE_DIR%" 2>nul
mkdir "%OUT_DIR%" 2>nul

:: --- Check Git ---
where git >nul 2>&1
if errorlevel 1 (
    echo [!] Git not found! Install: https://git-scm.com/download/win
    pause
    exit /b 1
)

:: --- Check GPU ---
where nvidia-smi >nul 2>&1
if errorlevel 1 (
    echo [!] NVIDIA driver not found!
    pause
    exit /b 1
)
echo [GPU]
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
echo.

:: --- Fix broken/partial Wan2GP folder ---
if exist "%INSTALL_DIR%" (
    if not exist "%INSTALL_DIR%\setup.py" (
        echo [!] Broken Wan2GP folder detected - removing...
        rmdir /s /q "%INSTALL_DIR%" 2>nul
        timeout /t 2 /nobreak >nul
    )
)

:: --- Clone Wan2GP (do NOT create Wan2GP folder before this!) ---
if not exist "%INSTALL_DIR%\setup.py" (
    echo [*] Downloading Wan2GP...
    git clone --depth 1 https://github.com/deepbeepmeep/Wan2GP.git "%INSTALL_DIR%"
    if errorlevel 1 (
        echo.
        echo [!] git clone failed!
        echo     If folder exists, delete manually:
        echo     %INSTALL_DIR%
        echo     Then run this .bat again.
        pause
        exit /b 1
    )
)

if not exist "%INSTALL_DIR%\setup.py" (
    echo [!] setup.py not found. Clone incomplete.
    pause
    exit /b 1
)
echo [+] Wan2GP downloaded OK
cd /d "%INSTALL_DIR%"

:: --- Install Python env ---
if not exist "%INSTALL_DIR%\env_venv\Scripts\python.exe" (
    echo.
    echo [*] Installing Python + PyTorch + deps...
    echo     15-40 minutes. Do not close this window!
    echo.
    where python >nul 2>&1
    if errorlevel 1 (
        echo [!] Python 3.11+ required!
        echo     https://www.python.org/downloads/
        echo     Check "Add Python to PATH" during install.
        pause
        exit /b 1
    )
    echo 1| python setup.py install --env venv --auto
    if errorlevel 1 (
        echo.
        echo [!] Auto install failed. Try manually:
        echo     cd /d %INSTALL_DIR%
        echo     scripts\install.bat
        pause
        exit /b 1
    )
)

set "PYTHON=%INSTALL_DIR%\env_venv\Scripts\python.exe"
if not exist "%PYTHON%" (
    echo [!] venv Python not found: %PYTHON%
    echo     Delete folder and retry: %INSTALL_DIR%\env_venv
    pause
    exit /b 1
)
echo [+] Python OK

:: --- Create loras folder (after clone) ---
mkdir "%LORA_DIR%" 2>nul

:: --- GTX 1650 config ---
(
echo {
echo     "attention_mode": "sdpa",
echo     "compile": "",
echo     "video_profile": 5,
echo     "image_profile": 5,
echo     "audio_profile": 5
echo }
) > "%INSTALL_DIR%\wgp_config.json"

:: --- Download model 1.3B ---
echo.
echo [*] Downloading Wan 2.1 T2V 1.3B model...
"%PYTHON%" -m pip install -q huggingface_hub
"%PYTHON%" -c "from huggingface_hub import hf_hub_download; import os; d=os.path.join(r'%INSTALL_DIR%','ckpts'); os.makedirs(d,exist_ok=True); p=hf_hub_download('DeepBeepMeep/Wan2.1','wan2.1_text2video_1.3B_mbf16.safetensors',local_dir=d); print('Model OK:',p)"
if errorlevel 1 (
    echo [!] Model download failed. Check internet.
    pause
    exit /b 1
)

:: --- Cursor MCP ---
echo.
echo [*] Configuring Cursor MCP...
mkdir "C:\Users\Owner\.cursor" 2>nul
"%PYTHON%" -c "import json;d={'mcpServers':{'wangp':{'command':r'%PYTHON%','args':[r'%INSTALL_DIR%\wgp.py','--mcp','--mcp-transport','stdio','--profile','5','--attention','sdpa','--config',r'%INSTALL_DIR%','--output-dir',r'%OUT_DIR%'],'cwd':r'%INSTALL_DIR%'}}};json.dump(d,open(r'%CURSOR_MCP%','w'),indent=2)"

:: --- README ---
(
echo NSFW Video Generator
echo Wan2GP:  %INSTALL_DIR%
echo Videos:  %OUT_DIR%
echo LoRAs:   %LORA_DIR%
echo MCP:     %CURSOR_MCP%
echo.
echo GTX 1650: model 1.3B, 480p, 25 frames, 15-20 steps
echo Cursor: Reload Window -^> MCP wangp green
) > "%BASE_DIR%\README.txt"

echo.
echo  ============================================================
echo    INSTALLATION COMPLETE!
echo  ============================================================
echo  Videos: %OUT_DIR%
echo  LoRAs:  %LORA_DIR%
echo.
echo  1. Reload Cursor
echo  2. MCP -^> wangp green
echo  3. start-chrome-no-gpu.bat ^(free VRAM^)
echo  4. Chat: Сгенерируй видео: prompt, 480p, 25 frames
echo.
pause
