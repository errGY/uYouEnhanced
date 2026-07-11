@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title NSFW Video Setup - GTX 1650

set "BASE_DIR=C:\Users\Owner\Videos\NSFW"
set "INSTALL_DIR=%BASE_DIR%\Wan2GP"
set "TEMP_DIR=%BASE_DIR%\_wan2gp_tmp"
set "OUT_DIR=%BASE_DIR%\generated"
set "LORA_DIR=%INSTALL_DIR%\models\loras"
set "CURSOR_MCP=C:\Users\Owner\.cursor\mcp.json"

echo.
echo  ============================================================
echo    NSFW Video Generator - Wan2GP Install  [v2]
echo    %BASE_DIR%
echo  ============================================================
echo.

mkdir "%BASE_DIR%" 2>nul
mkdir "%OUT_DIR%" 2>nul

where git >nul 2>&1
if errorlevel 1 (
    echo [!] Install Git: https://git-scm.com/download/win
    pause & exit /b 1
)

where nvidia-smi >nul 2>&1
if errorlevel 1 (
    echo [!] Install NVIDIA driver
    pause & exit /b 1
)
echo [GPU]
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
echo.

:: ===== DOWNLOAD Wan2GP =====
if not exist "%INSTALL_DIR%\setup.py" (

    echo [*] Cleaning old broken folders...
    if exist "%TEMP_DIR%" rmdir /s /q "%TEMP_DIR%" 2>nul
    if exist "%INSTALL_DIR%" (
        echo     Removing: %INSTALL_DIR%
        rmdir /s /q "%INSTALL_DIR%" 2>nul
        if exist "%INSTALL_DIR%" (
            echo.
            echo [!] Cannot delete %INSTALL_DIR%
            echo     Close all programs using this folder.
            echo     Or run FIX-REINSTALL.bat as Administrator.
            echo     Or manually delete the folder in Explorer.
            pause & exit /b 1
        )
    )
    timeout /t 1 /nobreak >nul

    echo [*] Downloading Wan2GP to temp folder...
    git clone --depth 1 https://github.com/deepbeepmeep/Wan2GP.git "%TEMP_DIR%"
    if errorlevel 1 (
        echo [!] git clone FAILED. Check internet.
        pause & exit /b 1
    )

    if not exist "%TEMP_DIR%\setup.py" (
        echo [!] Download incomplete - no setup.py
        pause & exit /b 1
    )

    echo [*] Moving to %INSTALL_DIR%...
    move "%TEMP_DIR%" "%INSTALL_DIR%" >nul
    if errorlevel 1 (
        echo [!] Move failed. Trying rename...
        ren "%TEMP_DIR%" "Wan2GP"
    )
)

if not exist "%INSTALL_DIR%\setup.py" (
    echo [!] ERROR: setup.py still missing!
    echo     Run FIX-REINSTALL.bat then try again.
    pause & exit /b 1
)
echo [+] Wan2GP OK
cd /d "%INSTALL_DIR%"

:: ===== INSTALL DEPS =====
if not exist "%INSTALL_DIR%\env_venv\Scripts\python.exe" (
    echo.
    echo [*] Installing Python + PyTorch ^(15-40 min^)...
    echo     DO NOT CLOSE THIS WINDOW!
    echo.
    where python >nul 2>&1
    if errorlevel 1 (
        echo [!] Python 3.11+ needed: https://www.python.org/downloads/
        pause & exit /b 1
    )
    echo 1| python setup.py install --env venv --auto
    if errorlevel 1 (
        echo [!] Install failed. Run: scripts\install.bat
        pause & exit /b 1
    )
)

set "PYTHON=%INSTALL_DIR%\env_venv\Scripts\python.exe"
if not exist "%PYTHON%" (
    echo [!] No venv python. Delete %INSTALL_DIR%\env_venv and retry.
    pause & exit /b 1
)
echo [+] Python OK
mkdir "%LORA_DIR%" 2>nul

:: ===== CONFIG =====
(
echo {
echo     "attention_mode": "sdpa",
echo     "compile": "",
echo     "video_profile": 5,
echo     "image_profile": 5,
echo     "audio_profile": 5
echo }
) > "%INSTALL_DIR%\wgp_config.json"

:: ===== MODEL =====
echo.
echo [*] Downloading Wan 2.1 model 1.3B ^(~1.5 GB^)...
"%PYTHON%" -m pip install -q huggingface_hub
"%PYTHON%" -c "from huggingface_hub import hf_hub_download;import os;d=os.path.join(r'%INSTALL_DIR%','ckpts');os.makedirs(d,exist_ok=True);p=hf_hub_download('DeepBeepMeep/Wan2.1','wan2.1_text2video_1.3B_mbf16.safetensors',local_dir=d);print('OK:',p)"
if errorlevel 1 (
    echo [!] Model download failed
    pause & exit /b 1
)

:: ===== MCP =====
echo [*] Cursor MCP config...
mkdir "C:\Users\Owner\.cursor" 2>nul
"%PYTHON%" -c "import json;d={'mcpServers':{'wangp':{'command':r'%PYTHON%','args':[r'%INSTALL_DIR%\wgp.py','--mcp','--mcp-transport','stdio','--profile','5','--attention','sdpa','--config',r'%INSTALL_DIR%','--output-dir',r'%OUT_DIR%'],'cwd':r'%INSTALL_DIR%'}}};json.dump(d,open(r'%CURSOR_MCP%','w'),indent=2)"

echo.
echo  ============================================================
echo    DONE!  Videos: %OUT_DIR%
echo  ============================================================
echo  1. Reload Cursor
echo  2. MCP -^> wangp green
echo  3. %INSTALL_DIR%\scripts\start-chrome-no-gpu.bat
echo.
pause
