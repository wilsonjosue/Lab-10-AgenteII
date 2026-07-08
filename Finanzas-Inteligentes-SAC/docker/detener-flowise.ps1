# Detiene Flowise (los datos se conservan en el volumen).
# Para borrar TODO (incluyendo flujos), usa:  docker compose down -v
$ErrorActionPreference = "Stop"
Set-Location -Path $PSScriptRoot
Write-Host "==> Deteniendo Flowise..." -ForegroundColor Cyan
docker compose down
Write-Host "==> Detenido. Los flujos y credenciales se conservan." -ForegroundColor Green
