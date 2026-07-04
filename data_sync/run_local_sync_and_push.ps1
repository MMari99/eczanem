$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Git = "C:\Program Files\Git\cmd\git.exe"

Set-Location $ProjectRoot

Write-Host "Eczanem gunluk veri guncelleme basladi..."
node data_sync/sync_pharmacies.mjs

& $Git pull --rebase origin main
& $Git add public/data/pharmacies_latest.json

$changes = & $Git status --porcelain public/data/pharmacies_latest.json
if ([string]::IsNullOrWhiteSpace($changes)) {
  Write-Host "Veri dosyasinda degisiklik yok."
  exit 0
}

& $Git commit -m "Update local daily pharmacy data"
& $Git push
Write-Host "Gunluk veri GitHub tarafina gonderildi."
