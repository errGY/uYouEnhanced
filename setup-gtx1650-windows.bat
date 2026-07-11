@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ============================================================
echo   Wan2GP Setup for GTX 1650 4GB + 32GB RAM
echo ============================================================
echo.

set "INSTALL_DIR=%USERPROFILE%\Wan2GP"
set "CURSOR_MCP=%USERPROFILE%\.cursor\mcp.json"

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
    echo [*] Cloning Wan2GP...
    git clone https://github.com/deepbeepmeep/Wan2GP.git "%INSTALL_DIR%"
)
cd /d "%INSTALL_DIR%"

:: --- Auto install (GTX 16xx = GTX_10 profile, CUDA 12.8) ---
if not exist "%INSTALL_DIR%\env_venv\Scripts\python.exe" (
    echo [*] Installing dependencies - this takes 15-40 minutes...
    echo 1| python setup.py install --env venv --auto
    if %errorlevel% neq 0 (
        echo [!] Auto install failed. Try manually: scripts\install.bat
        pause
        exit /b 1
    )
)

set "PYTHON=%INSTALL_DIR%\env_venv\Scripts\python.exe"
echo [+] Python: %PYTHON%

:: --- GTX 1650 optimized config ---
echo [*] Writing low-VRAM config (profile 5)...
(
echo {
echo     "attention_mode": "sdpa",
echo     "compile": "",
echo     "video_profile": 5,
echo     "image_profile": 5,
echo     "audio_profile": 5
echo }
) > "%INSTALL_DIR%\wgp_config.json"

:: --- Download Wan 2.1 T2V 1.3B model (smallest, ~1.5GB mbf16) ---
echo [*] Downloading Wan 2.1 T2V 1.3B model...
"%PYTHON%" -m pip install -q huggingface_hub
"%PYTHON%" -c "from huggingface_hub import hf_hub_download; import os; dest=os.path.join(r'%INSTALL_DIR%','ckpts'); os.makedirs(dest,exist_ok=True); p=hf_hub_download('DeepBeepMeep/Wan2.1', 'wan2.1_text2video_1.3B_mbf16.safetensors', local_dir=dest); print('Downloaded:', p)"

:: --- Create outputs folder ---
if not exist "%INSTALL_DIR%\outputs" mkdir "%INSTALL_DIR%\outputs"
if not exist "%INSTALL_DIR%\models\loras" mkdir "%INSTALL_DIR%\models\loras"

:: --- Cursor MCP config ---
echo [*] Configuring Cursor MCP...
if not exist "%USERPROFILE%\.cursor" mkdir "%USERPROFILE%\.cursor"
"%PYTHON%" -c "import json,os; d={'mcpServers':{'wangp':{'command':r'%PYTHON%','args':[r'%INSTALL_DIR%\wgp.py','--mcp','--mcp-transport','stdio','--profile','5','--attention','sdpa','--config',r'%INSTALL_DIR%','--output-dir',r'%INSTALL_DIR%\outputs'],'cwd':r'%INSTALL_DIR%'}}}; os.makedirs(os.path.dirname(r'%CURSOR_MCP%'),exist_ok=True); json.dump(d,open(r'%CURSOR_MCP%','w'),indent=2)"

echo.
echo ============================================================
echo   INSTALLATION COMPLETE
echo ============================================================
echo.
echo NEXT STEPS:
echo   1. Close Chrome/Edge GPU usage (saves ~1GB VRAM^):
echo      Run: %INSTALL_DIR%\scripts\start-chrome-no-gpu.bat
echo   2. Reload Cursor: Ctrl+Shift+P -^> Reload Window
echo   3. Settings -^> MCP -^> check 'wangp' is green
echo   4. In Agent chat write:
echo      Generate video: a cat walking, 480p, 25 frames
echo.
echo RECOMMENDED SETTINGS (GTX 1650 4GB^):
echo   Model:     Wan 2.1 Text2video 1.3B
echo   Profile:   5 (auto^)
echo   Lora:      Causvid Rank32 - 8 Steps (faster^)
echo   Frames:    25-33 (1 second^)
echo   Steps:     15-20
echo   Resolution: 480p or lower
echo.
echo PATHS:
echo   Wan2GP:  %INSTALL_DIR%
echo   Videos:  %INSTALL_DIR%\outputs
echo   MCP:     %CURSOR_MCP%
echo.
echo IF OUT OF MEMORY - use ComfyUI+GGUF fallback:
echo   See VIDEO-MCP-SETUP.md section "GTX 1650 4GB"
echo.
pause
