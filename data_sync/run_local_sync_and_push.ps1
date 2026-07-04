$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Git = "C:\Program Files\Git\cmd\git.exe"
$Node = "C:\Program Files\nodejs\node.exe"

Set-Location $ProjectRoot

Write-Host "Eczanem gunluk veri guncelleme basladi..."
& $Node data_sync/sync_pharmacies.mjs
if ($LASTEXITCODE -ne 0) { throw "Veri guncelleme scripti basarisiz oldu." }

& $Git pull --rebase origin main
if ($LASTEXITCODE -ne 0) { throw "Git pull basarisiz oldu." }

& $Git add public/data/pharmacies_latest.json

$changes = & $Git status --porcelain public/data/pharmacies_latest.json
if ([string]::IsNullOrWhiteSpace($changes)) {
  Write-Host "Veri dosyasinda degisiklik yok."
  exit 0
}

& $Git commit -m "Update local daily pharmacy data"
if ($LASTEXITCODE -ne 0) { throw "Git commit basarisiz oldu." }

& $Git push
if ($LASTEXITCODE -ne 0) { throw "Git push basarisiz oldu." }

Write-Host "Gunluk veri GitHub tarafina gonderildi."
