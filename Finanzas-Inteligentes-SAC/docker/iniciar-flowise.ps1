# Inicia Flowise en Docker y abre el navegador.
# Uso: clic derecho > "Ejecutar con PowerShell", o en terminal:  .\iniciar-flowise.ps1
$ErrorActionPreference = "Stop"
Set-Location -Path $PSScriptRoot

Write-Host "==> Levantando Flowise (FinBot) en Docker..." -ForegroundColor Cyan
docker compose up -d

Write-Host "==> Esperando a que Flowise responda en http://localhost:3000 ..." -ForegroundColor Cyan
$ok = $false
for ($i = 0; $i -lt 40; $i++) {
    try {
        $r = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 3
        if ($r.StatusCode -eq 200) { $ok = $true; break }
    } catch { Start-Sleep -Seconds 3 }
}

if ($ok) {
    Write-Host "==> Flowise LISTO en http://localhost:3000" -ForegroundColor Green
    Write-Host "    Usuario: admin   Password: admin123" -ForegroundColor Green
    Start-Process "http://localhost:3000"
} else {
    Write-Host "==> Flowise aun no responde. Revisa: docker compose logs -f" -ForegroundColor Yellow
}
