# Wan2GP Video Generation — установка для Cursor MCP

## Быстрый старт (на вашем ПК с NVIDIA GPU)

```bash
chmod +x setup-video-mcp.sh
./setup-video-mcp.sh
```

Затем в Cursor: **Reload Window** → Settings → MCP → `wangp` должен быть зелёным.

## Что установлено в Cloud Agent (частично)

| Компонент | Статус |
|-----------|--------|
| Wan2GP код | `/home/ubuntu/Wan2GP` |
| Python 3.11 env | `/home/ubuntu/Wan2GP/env_venv` |
| PyTorch 2.10 + CUDA 13 | установлен |
| Зависимости (273 пакета) | установлены |
| Модели Wan 2.1 T2V 1.3B | ~9 GB скачаны |
| MCP конфиг | `~/.cursor/mcp.json` |

**Ограничение:** на Cloud Agent нет NVIDIA GPU → генерация видео здесь не работает.  
Запустите `setup-video-mcp.sh` на **своём компьютере** с видеокартой.

## MCP конфиг (Windows)

Замените пути в `C:\Users\ВАШ_ЮЗЕР\.cursor\mcp.json`:

```json
{
  "mcpServers": {
    "wangp": {
      "command": "C:\\Users\\ВАШ_ЮЗЕР\\Wan2GP\\env_venv\\Scripts\\python.exe",
      "args": [
        "C:\\Users\\ВАШ_ЮЗЕР\\Wan2GP\\wgp.py",
        "--mcp",
        "--mcp-transport",
        "stdio",
        "--config",
        "C:\\Users\\ВАШ_ЮЗЕР\\Wan2GP",
        "--output-dir",
        "C:\\Users\\ВАШ_ЮЗЕР\\Wan2GP\\outputs"
      ],
      "cwd": "C:\\Users\\ВАШ_ЮЗЕР\\Wan2GP"
    }
  }
}
```

## Использование в Cursor Agent

```
Сгенерируй видео: cinematic shot of rain in city, 480p, 3 seconds
```

Агент вызовет `wangp_list_models` → `wangp_generate` → вернёт путь к `.mp4`.

## NSFW LoRA

1. Скачайте с https://civitai.com/models?baseModel=Wan%20Video%202.1
2. Положите в `Wan2GP/models/loras/`
3. Укажите в промпте имя LoRA

## Ссылки на модели

- ComfyUI repack: https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged
- Wan2GP: https://github.com/deepbeepmeep/Wan2GP
- API docs: https://github.com/deepbeepmeep/Wan2GP/blob/main/docs/API.md
