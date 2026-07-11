# Wan2GP Video Generation — установка для Cursor MCP

## GTX 1650 4GB + 32GB RAM — ваш случай

У вас **4 GB VRAM** — это ниже официального минимума Wan2GP (6 GB), но **32 GB RAM** позволяет использовать агрессивный offload. Работать будет, но медленно (~5–15 минут на 1 секунду видео).

### Установка одной командой (Windows)

1. Скачайте `setup-gtx1650-windows.bat` из репозитория
2. Запустите **от имени обычного пользователя** (двойной клик)
3. Дождитесь окончания (~20–40 мин первый раз)

Или вручную в PowerShell:

```powershell
git clone https://github.com/errGY/uYouEnhanced.git
cd uYouEnhanced
.\setup-gtx1650-windows.bat
```

### После установки

1. **Освободите VRAM** — закройте игры, браузер с GPU-ускорением:
   ```
   %USERPROFILE%\Wan2GP\scripts\start-chrome-no-gpu.bat
   ```
2. **Cursor** → `Ctrl+Shift+P` → `Reload Window`
3. **Settings → MCP** → `wangp` должен быть зелёным
4. В Agent-чате:

```
Сгенерируй видео: woman walking on beach at sunset, 480p, 25 frames, model t2v_1.3B
```

### Оптимальные настройки для GTX 1650

| Параметр | Значение | Почему |
|----------|----------|--------|
| **Модель** | Wan 2.1 Text2video **1.3B** | Единственная реалистичная для 4 GB |
| **Profile** | **5** (макс. offload в RAM) | Авто в `wgp_config.json` |
| **Lora preset** | `Causvid Rank32 - 8 Steps` | Быстрее, меньше VRAM |
| **Кадры** | **25–33** (~1 сек) | Меньше = меньше памяти |
| **Steps** | **15–20** | Баланс скорость/качество |
| **Разрешение** | **480p** (832×480 или ниже) | 720p не влезет |
| **Attention** | `sdpa` | Sage не работает на GTX 16xx |

### Если вылетает Out of Memory (OOM)

Попробуйте по порядку:

1. Закройте **все** программы, использующие GPU (Discord, OBS, браузер)
2. Запустите Chrome без GPU: `scripts\start-chrome-no-gpu.bat`
3. Уменьшите кадры до **17** (0.7 сек)
4. Уменьшите steps до **12**
5. **Запасной план — ComfyUI + GGUF** (точно работает на 4 GB):

| Файл | Ссылка | Размер |
|------|--------|--------|
| T2V 1.3B Q3_K_M | [calcuis/wan-1.3b-gguf](https://huggingface.co/calcuis/wan-1.3b-gguf/blob/main/wan2.1_t2v_1.3b-q3_k_m.gguf) | ~700 MB |
| Text encoder Q4 | [umt5-xxl-encoder-q4_k_m.gguf](https://huggingface.co/calcuis/wan-1.3b-gguf/blob/main/umt5-xxl-encoder-q4_k_m.gguf) | ~1.5 GB |
| VAE | [pig_wan_vae_fp32-f16.gguf](https://huggingface.co/calcuis/wan-1.3b-gguf/blob/main/pig_wan_vae_fp32-f16.gguf) | ~250 MB |

Workflow для 4 GB: [The-frizzy1/Wan21-GGUF-4GB-Workflow](https://huggingface.co/The-frizzy1/Wan21-GGUF-4GB-Workflow)

### NSFW без цензуры

1. LoRA с [Civitai — Wan Video 2.1](https://civitai.com/models?baseModel=Wan%20Video%202.1)
2. Положите в `%USERPROFILE%\Wan2GP\models\loras\`
3. В промпте агенту укажите имя файла LoRA

Локальная генерация **без фильтров** — ограничения только ваши.

---

## Быстрый старт (любой NVIDIA GPU)

```bash
chmod +x setup-video-mcp.sh
./setup-video-mcp.sh
```

Затем в Cursor: **Reload Window** → Settings → MCP → `wangp` должен быть зелёным.

## MCP конфиг (Windows, GTX 1650)

Файл `%USERPROFILE%\.cursor\mcp.json` (создаётся автоматически скриптом):

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
        "--profile",
        "5",
        "--attention",
        "sdpa",
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
Сгенерируй видео: cinematic shot of rain in city, 480p, 25 frames
```

Агент вызовет `wangp_list_models` → `wangp_generate` → вернёт путь к `.mp4`.

## Ссылки

- Wan2GP: https://github.com/deepbeepmeep/Wan2GP
- Модель 1.3B: https://huggingface.co/DeepBeepMeep/Wan2.1
- GGUF 4GB: https://huggingface.co/calcuis/wan-1.3b-gguf
- API docs: https://github.com/deepbeepmeep/Wan2GP/blob/main/docs/API.md
