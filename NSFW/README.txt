NSFW Video Generation — C:\Users\Owner\Videos\NSFW
===================================================

СТРУКТУРА ПАПОК (после установки):
  C:\Users\Owner\Videos\NSFW\
  ├── setup-gtx1650-windows.bat   ← запустить ЭТОТ файл
  ├── wgp_config.json             ← конфиг GTX 1650 4GB
  ├── cursor-mcp.json             ← скопировать в C:\Users\Owner\.cursor\mcp.json
  ├── README.txt                  ← этот файл
  ├── generated\                  ← сюда падают готовые видео
  └── Wan2GP\                     ← создаётся скриптом (код + модели)

УСТАНОВКА:
  1. Двойной клик на setup-gtx1650-windows.bat
  2. Дождаться окончания (20-40 мин)
  3. Cursor: Ctrl+Shift+P → Reload Window
  4. Settings → MCP → wangp зелёный

ИСПОЛЬЗОВАНИЕ В CURSOR:
  Сгенерируй видео: your prompt here, 480p, 25 frames

NSFW LORA:
  Скачать: https://civitai.com/models?baseModel=Wan%20Video%202.1
  Положить в: C:\Users\Owner\Videos\NSFW\Wan2GP\models\loras\

НАСТРОЙКИ GTX 1650 4GB:
  Модель:  Wan 2.1 Text2video 1.3B
  Кадры:   25-33
  Steps:   15-20
  Разрешение: 480p

ЕСЛИ OOM (нехватка VRAM):
  Запустить: Wan2GP\scripts\start-chrome-no-gpu.bat
  Или ComfyUI+GGUF: https://huggingface.co/calcuis/wan-1.3b-gguf
