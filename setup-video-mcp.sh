#!/bin/bash
# Wan2GP + Cursor MCP — полная установка для локальной машины с NVIDIA GPU
# Запуск: chmod +x setup-video-mcp.sh && ./setup-video-mcp.sh

set -e

INSTALL_DIR="${WAN2GP_DIR:-$HOME/Wan2GP}"
CURSOR_MCP="${CURSOR_MCP:-$HOME/.cursor/mcp.json}"

echo "============================================"
echo "  Wan2GP Video Generator + Cursor MCP Setup"
echo "============================================"

# --- 1. Проверка GPU ---
if ! command -v nvidia-smi &>/dev/null; then
    echo "[!] NVIDIA GPU не найден. Генерация видео не будет работать."
    echo "    Установка продолжится для настройки MCP."
else
    echo "[+] GPU: $(nvidia-smi --query-gpu=name --format=csv,noheader | head -1)"
    echo "[+] VRAM: $(nvidia-smi --query-gpu=memory.total --format=csv,noheader | head -1)"
fi

# --- 2. Клонирование Wan2GP ---
if [ ! -d "$INSTALL_DIR/.git" ]; then
    echo "[*] Клонируем Wan2GP..."
    git clone https://github.com/deepbeepmeep/Wan2GP.git "$INSTALL_DIR"
fi
cd "$INSTALL_DIR"

# --- 3. Автоустановка зависимостей ---
if [ ! -f "$INSTALL_DIR/env_venv/bin/python" ] && [ ! -f "$INSTALL_DIR/env_venv/Scripts/python.exe" ]; then
    echo "[*] Устанавливаем зависимости (может занять 10-30 мин)..."
    if [ -f "$INSTALL_DIR/scripts/install.sh" ]; then
        echo "1" | bash "$INSTALL_DIR/scripts/install.sh" || python3 setup.py install --env venv --auto
    else
        python3 setup.py install --env venv --auto
    fi
fi

# Определяем Python из venv
if [ -f "$INSTALL_DIR/env_venv/bin/python" ]; then
    PYTHON="$INSTALL_DIR/env_venv/bin/python"
elif [ -f "$INSTALL_DIR/env_venv/Scripts/python.exe" ]; then
    PYTHON="$INSTALL_DIR/env_venv/Scripts/python.exe"
else
    PYTHON="python3"
fi

echo "[+] Python: $PYTHON"

# --- 4. Скачивание моделей Wan 2.1 (1.3B — минимум VRAM) ---
echo "[*] Скачиваем модели Wan 2.1 T2V 1.3B..."
$PYTHON -m pip install -q "huggingface_hub[cli]"

mkdir -p "$INSTALL_DIR/models"/{diffusion_models,text_encoders,vae,loras}
HF_DIR="$INSTALL_DIR/models_hf"

huggingface-cli download Comfy-Org/Wan_2.1_ComfyUI_repackaged \
    --include "split_files/diffusion_models/wan2.1_t2v_1.3B_fp16.safetensors" \
    --include "split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors" \
    --include "split_files/vae/wan_2.1_vae.safetensors" \
    --local-dir "$HF_DIR"

# Перемещаем файлы в правильные папки
cp -n "$HF_DIR/split_files/diffusion_models/"*.safetensors "$INSTALL_DIR/models/diffusion_models/" 2>/dev/null || true
cp -n "$HF_DIR/split_files/text_encoders/"*.safetensors "$INSTALL_DIR/models/text_encoders/" 2>/dev/null || true
cp -n "$HF_DIR/split_files/vae/"*.safetensors "$INSTALL_DIR/models/vae/" 2>/dev/null || true

echo "[+] Модели:"
ls -lh "$INSTALL_DIR/models/diffusion_models/" 2>/dev/null || echo "  (скачиваются...)"

# --- 5. Папка для выходных видео ---
mkdir -p "$INSTALL_DIR/outputs"

# --- 6. MCP конфиг для Cursor ---
echo "[*] Настраиваем Cursor MCP..."

MCP_CONFIG=$(cat << EOF
{
  "mcpServers": {
    "wangp": {
      "command": "$PYTHON",
      "args": [
        "$INSTALL_DIR/wgp.py",
        "--mcp",
        "--mcp-transport",
        "stdio",
        "--config",
        "$INSTALL_DIR",
        "--output-dir",
        "$INSTALL_DIR/outputs"
      ],
      "cwd": "$INSTALL_DIR"
    }
  }
}
EOF
)

mkdir -p "$(dirname "$CURSOR_MCP")"

# Мержим с существующим mcp.json если есть
if [ -f "$CURSOR_MCP" ]; then
    echo "[*] Обновляем существующий $CURSOR_MCP (добавляем wangp)..."
    # Простая замена — бэкап
    cp "$CURSOR_MCP" "$CURSOR_MCP.bak.$(date +%s)"
fi

echo "$MCP_CONFIG" > "$CURSOR_MCP"
echo "[+] MCP конфиг записан: $CURSOR_MCP"

# --- 7. Готово ---
echo ""
echo "============================================"
echo "  УСТАНОВКА ЗАВЕРШЕНА"
echo "============================================"
echo ""
echo "Следующие шаги:"
echo "  1. Перезагрузите Cursor: Ctrl+Shift+P → 'Reload Window'"
echo "  2. Settings → MCP → проверьте что 'wangp' зелёный"
echo "  3. В Agent-чате напишите:"
echo "     'Сгенерируй видео: cinematic rain scene, 480p'"
echo ""
echo "Пути:"
echo "  Wan2GP:  $INSTALL_DIR"
echo "  Модели:  $INSTALL_DIR/models/"
echo "  Видео:   $INSTALL_DIR/outputs/"
echo "  MCP:     $CURSOR_MCP"
echo ""
echo "Для NSFW LoRA — скачайте с civitai.com и положите в:"
echo "  $INSTALL_DIR/models/loras/"
echo ""
echo "Полезные ссылки:"
echo "  Модели HF:  https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged"
echo "  LoRA:       https://civitai.com/models?baseModel=Wan%20Video%202.1"
echo "  API docs:   https://github.com/deepbeepmeep/Wan2GP/blob/main/docs/API.md"
