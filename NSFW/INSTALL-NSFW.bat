@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title NSFW Video Setup - GTX 1650 [v3]

:: GTX 1650 bug: Wan2GP sees "50" in name -> thinks RTX 50 -> needs Python 3.11
:: This script uses Python 3.10 + CUDA 12.8 (correct for GTX 16xx)

set "BASE_DIR=C:\Users\Owner\Videos\NSFW"
set "INSTALL_DIR=%BASE_DIR%\Wan2GP"
set "TEMP_DIR=%BASE_DIR%\_wan2gp_tmp"
set "OUT_DIR=%BASE_DIR%\generated"
set "LORA_DIR=%INSTALL_DIR%\models\loras"
set "CURSOR_MCP=C:\Users\Owner\.cursor\mcp.json"
set "VENV=%INSTALL_DIR%\env_venv"

echo.
echo  ============================================================
echo    NSFW Video Generator - GTX 1650 Install  [v3]
echo    Python 3.10 + CUDA 12.8 ^(fix for GTX 16xx^)
echo  ============================================================
echo.

mkdir "%BASE_DIR%" 2>nul
mkdir "%OUT_DIR%" 2>nul

where git >nul 2>&1
if errorlevel 1 (echo [!] Install Git & pause & exit /b 1)

where nvidia-smi >nul 2>&1
if errorlevel 1 (echo [!] Install NVIDIA driver & pause & exit /b 1)

echo [GPU]
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
echo.

:: Check Python 3.10
py -3.10 -c "import sys; print(sys.version)" >nul 2>&1
if errorlevel 1 (
    echo [!] Python 3.10 not found!
    echo.
    echo     You have 3.14 but Wan2GP needs 3.10 for GTX 1650.
    echo     Download: https://www.python.org/downloads/release/python-31011/
    echo     During install check "Add Python to PATH"
    echo     Also check "py launcher" option.
    echo.
    pause & exit /b 1
)
echo [+] Python 3.10 OK
echo.

:: ===== DOWNLOAD =====
if not exist "%INSTALL_DIR%\setup.py" (
    echo [*] Cleaning old folders...
    if exist "%TEMP_DIR%" rmdir /s /q "%TEMP_DIR%" 2>nul
    if exist "%INSTALL_DIR%" rmdir /s /q "%INSTALL_DIR%" 2>nul
    if exist "%INSTALL_DIR%" (
        echo [!] Delete manually: %INSTALL_DIR%
        pause & exit /b 1
    )
    echo [*] Downloading Wan2GP...
    git clone --depth 1 https://github.com/deepbeepmeep/Wan2GP.git "%TEMP_DIR%"
    if errorlevel 1 (echo [!] git clone failed & pause & exit /b 1)
    move "%TEMP_DIR%" "%INSTALL_DIR%" >nul
)
if not exist "%INSTALL_DIR%\setup.py" (echo [!] No setup.py & pause & exit /b 1)
echo [+] Wan2GP OK
cd /d "%INSTALL_DIR%"

:: ===== VENV with Python 3.10 (NOT setup.py --auto!) =====
if not exist "%VENV%\Scripts\python.exe" (
    echo.
    echo [*] Creating venv with Python 3.10...
    py -3.10 -m venv "%VENV%"
    if errorlevel 1 (echo [!] venv failed & pause & exit /b 1)

    set "PIP=%VENV%\Scripts\pip.exe"
    echo [*] Upgrading pip...
    "%VENV%\Scripts\python.exe" -m pip install --upgrade pip

    echo.
    echo [*] Installing PyTorch 2.7.1 + CUDA 12.8...
    echo     ~5-10 minutes...
    "%PIP%" install torch==2.7.1 torchvision==0.22.1 torchaudio==2.7.1 --index-url https://download.pytorch.org/whl/test/cu128
    if errorlevel 1 (echo [!] PyTorch install failed & pause & exit /b 1)

    echo.
    echo [*] Installing requirements.txt...
    echo     ~15-30 minutes. DO NOT CLOSE!
    "%PIP%" install -r requirements.txt
    if errorlevel 1 (echo [!] requirements failed & pause & exit /b 1)

    echo [+] Dependencies installed
)

set "PYTHON=%VENV%\Scripts\python.exe"
if not exist "%PYTHON%" (echo [!] No python in venv & pause & exit /b 1)
echo [+] Python: %PYTHON%
mkdir "%LORA_DIR%" 2>nul

:: ===== Config for GTX 1650 =====
(
echo {
echo     "attention_mode": "sdpa",
echo     "compile": "",
echo     "video_profile": 5,
echo     "image_profile": 5,
echo     "audio_profile": 5
echo }
) > "%INSTALL_DIR%\wgp_config.json"

:: ===== Model =====
echo.
echo [*] Downloading Wan 2.1 T2V 1.3B...
"%PYTHON%" -m pip install -q huggingface_hub
"%PYTHON%" -c "from huggingface_hub import hf_hub_download;import os;d=os.path.join(r'%INSTALL_DIR%','ckpts');os.makedirs(d,exist_ok=True);p=hf_hub_download('DeepBeepMeep/Wan2.1','wan2.1_text2video_1.3B_mbf16.safetensors',local_dir=d);print('OK:',p)"
if errorlevel 1 (echo [!] Model download failed & pause & exit /b 1)

:: ===== MCP =====
echo [*] Creating mcp.json...
mkdir "C:\Users\Owner\.cursor" 2>nul
"%PYTHON%" -c "import json;d={'mcpServers':{'wangp':{'command':r'%PYTHON%','args':[r'%INSTALL_DIR%\wgp.py','--mcp','--mcp-transport','stdio','--profile','5','--attention','sdpa','--config',r'%INSTALL_DIR%','--output-dir',r'%OUT_DIR%'],'cwd':r'%INSTALL_DIR%'}}};json.dump(d,open(r'%CURSOR_MCP%','w'),indent=2);print('MCP OK:',r'%CURSOR_MCP%')"

echo.
echo  ============================================================
echo    INSTALLATION COMPLETE!
echo  ============================================================
echo  Wan2GP:  %INSTALL_DIR%
echo  Videos:  %OUT_DIR%
echo  MCP:     %CURSOR_MCP%
echo.
echo  NEXT:
echo    1. Reload Cursor ^(Ctrl+Shift+P^)
echo    2. Customize -^> MCP -^> wangp GREEN
echo    3. start-chrome-no-gpu.bat
echo    4. Chat: Сгенерируй видео: sunset beach, 480p, 25 frames
echo.
pause
