# Скопировать setup-файлы на ваш ПК в C:\Users\Owner\Videos\NSFW
# Запустите в PowerShell от имени Owner:

$dest = "C:\Users\Owner\Videos\NSFW"
New-Item -ItemType Directory -Force -Path $dest | Out-Null
New-Item -ItemType Directory -Force -Path "$dest\generated" | Out-Null

# Если клонировали репо:
$src = "$PSScriptRoot"
if (-not (Test-Path "$src\setup-gtx1650-windows.bat")) {
    $src = (Get-Location).Path
}

Copy-Item "$src\setup-gtx1650-windows.bat" "$dest\" -Force
Copy-Item "$src\wgp_config.json" "$dest\" -Force
Copy-Item "$src\cursor-mcp.json" "$dest\" -Force
Copy-Item "$src\README.txt" "$dest\" -Force

# Cursor MCP
$mcpDir = "C:\Users\Owner\.cursor"
New-Item -ItemType Directory -Force -Path $mcpDir | Out-Null
Copy-Item "$src\cursor-mcp.json" "$mcpDir\mcp.json" -Force

Write-Host ""
Write-Host "Готово! Файлы в: $dest"
Write-Host "Запустите: $dest\setup-gtx1650-windows.bat"
Write-Host "MCP скопирован в: $mcpDir\mcp.json"
