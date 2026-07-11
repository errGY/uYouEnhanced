@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title NSFW Video Setup - GTX 1650

:: ================================================================
::  ОДИН ФАЙЛ — полная установка Wan2GP + Cursor MCP
::  Путь: C:\Users\Owner\Videos\NSFW
::  GPU:  GTX 1650 4GB + 32GB RAM
::
::  Как использовать:
::    1. Сохраните этот файл куда угодно (Рабочий стол, Downloads...)
::    2. Двойной клик
::    3. Ждите 20-40 минут
:: ================================================================

set "BASE_DIR=C:\Users\Owner\Videos\NSFW"
set "INSTALL_DIR=%BASE_DIR%\Wan2GP"
set "OUT_DIR=%BASE_DIR%\generated"
set "LORA_DIR=%BASE_DIR%\Wan2GP\models\loras"
set "CURSOR_MCP=C:\Users\Owner\.cursor\mcp.json"

echo.
echo  ============================================================
echo    NSFW Video Generator - Wan2GP Install
echo    Path: %BASE_DIR%
echo  ============================================================
echo.

:: --- Create folders ---
mkdir "%BASE_DIR%" 2>nul
mkdir "%OUT_DIR%" 2>nul
mkdir "%BASE_DIR%\Wan2GP\models\loras" 2>nul

:: --- Check Git ---
where git >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Git not found!
    echo.
    echo     Install Git: https://git-scm.com/download/win
    echo     Then run this .bat again.
    echo.
    pause
    exit /b 1
)

:: --- Check GPU ---
where nvidia-smi >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] NVIDIA driver not found!
    echo     https://www.nvidia.com/Download/index.aspx
    pause
    exit /b 1
)
echo [GPU]
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
echo.

:: --- Clone Wan2GP ---
if not exist "%INSTALL_DIR%\.git" (
    echo [*] Downloading Wan2GP...
    git clone --depth 1 https://github.com/deepbeepmeep/Wan2GP.git "%INSTALL_DIR%"
    if %errorlevel% neq 0 (
        echo [!] git clone failed
        pause
        exit /b 1
    )
)
cd /d "%INSTALL_DIR%"

:: --- Install Python env ---
if not exist "%INSTALL_DIR%\env_venv\Scripts\python.exe" (
    echo.
    echo [*] Installing Python + PyTorch + deps...
    echo     This takes 15-40 minutes. Do not close this window!
    echo.
    where python >nul 2>&1
    if %errorlevel% neq 0 (
        echo [!] Python 3.11+ required!
        echo     Download: https://www.python.org/downloads/
        echo     Check "Add Python to PATH" during install.
        pause
        exit /b 1
    )
    echo 1| python setup.py install --env venv --auto
    if %errorlevel% neq 0 (
        echo.
        echo [!] Auto install failed. Try manually:
        echo     cd %INSTALL_DIR%
        echo     scripts\install.bat
        pause
        exit /b 1
    )
)

set "PYTHON=%INSTALL_DIR%\env_venv\Scripts\python.exe"
if not exist "%PYTHON%" (
    echo [!] Python not found: %PYTHON%
    pause
    exit /b 1
)
echo [+] Python OK

:: --- GTX 1650 config (profile 5, max RAM offload) ---
(
echo {
echo     "attention_mode": "sdpa",
echo     "compile": "",
echo     "video_profile": 5,
echo     "image_profile": 5,
echo     "audio_profile": 5
echo }
) > "%INSTALL_DIR%\wgp_config.json"

:: --- Download Wan 2.1 model 1.3B (~1.5 GB) ---
echo.
echo [*] Downloading Wan 2.1 T2V 1.3B model...
"%PYTHON%" -m pip install -q huggingface_hub
"%PYTHON%" -c "from huggingface_hub import hf_hub_download; import os; d=os.path.join(r'%INSTALL_DIR%','ckpts'); os.makedirs(d,exist_ok=True); p=hf_hub_download('DeepBeepMeep/Wan2.1','wan2.1_text2video_1.3B_mbf16.safetensors',local_dir=d); print('Model OK:',p)"
if %errorlevel% neq 0 (
    echo [!] Model download failed. Check internet connection.
    pause
    exit /b 1
)

:: --- Cursor MCP config ---
echo.
echo [*] Configuring Cursor MCP...
mkdir "C:\Users\Owner\.cursor" 2>nul
"%PYTHON%" -c "import json;d={'mcpServers':{'wangp':{'command':r'%PYTHON%','args':[r'%INSTALL_DIR%\wgp.py','--mcp','--mcp-transport','stdio','--profile','5','--attention','sdpa','--config',r'%INSTALL_DIR%','--output-dir',r'%OUT_DIR%'],'cwd':r'%INSTALL_DIR%'}}};json.dump(d,open(r'%CURSOR_MCP%','w'),indent=2)"

:: --- Save readme ---
(
echo NSFW Video Generator
echo ====================
echo.
echo Wan2GP:    %INSTALL_DIR%
echo Videos:    %OUT_DIR%
echo LoRAs:     %LORA_DIR%
echo Cursor MCP: %CURSOR_MCP%
echo.
echo SETTINGS for GTX 1650 4GB:
echo   Model:      Wan 2.1 Text2video 1.3B
echo   Frames:     25-33
echo   Steps:      15-20
echo   Resolution: 480p
echo   Lora:       Causvid Rank32 - 8 Steps
echo.
echo CURSOR:
echo   1. Ctrl+Shift+P -^> Reload Window
echo   2. Settings -^> MCP -^> wangp = green
echo   3. Chat: Сгенерируй видео: your prompt, 480p, 25 frames
echo.
echo NSFW LORA:
echo   https://civitai.com/models?baseModel=Wan%%20Video%%202.1
echo   Save to: %LORA_DIR%
echo.
echo FREE VRAM before generation:
echo   %INSTALL_DIR%\scripts\start-chrome-no-gpu.bat
) > "%BASE_DIR%\README.txt"

:: --- Done ---
echo.
echo  ============================================================
echo    INSTALLATION COMPLETE!
echo  ============================================================
echo.
echo  Videos save to:  %OUT_DIR%
echo  NSFW LoRAs:      %LORA_DIR%
echo  Cursor MCP:      %CURSOR_MCP%
echo.
echo  NEXT:
echo    1. Reload Cursor  (Ctrl+Shift+P -^> Reload Window)
echo    2. Settings -^> MCP -^> wangp green
echo    3. Run: %INSTALL_DIR%\scripts\start-chrome-no-gpu.bat
echo    4. In Cursor chat:
echo       Сгенерируй видео: woman on beach, 480p, 25 frames
echo.
pause
