#requires -Version 5.1

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$backupDir = Join-Path $root 'driver-backup'
$readyMarker = Join-Path $backupDir 'BACKUP_OK.txt'

function Test-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Administrator)) {
    Write-Host 'HATA: Bu dosya yonetici yetkisiyle calistirilmali.' -ForegroundColor Red
    Write-Host '3_BLUETOOTHU_GERI_GETIR.bat dosyasina sag tiklayip "Yonetici olarak calistir" secin.'
    exit 1
}

if (-not (Test-Path $readyMarker)) {
    Write-Host 'HATA: Dogrulanmis surucu yedegi yok; otomatik geri yukleme yapilmadi.' -ForegroundColor Red
    exit 2
}

$originalInf = (Get-Content (Join-Path $backupDir 'original-inf.txt') -Raw).Trim()
$deviceId = (Get-Content (Join-Path $backupDir 'device-id.txt') -Raw).Trim()
$backupInfs = @(Get-ChildItem -Path $backupDir -Recurse -Filter '*.inf' -File)

if ($originalInf -notmatch '^oem\d+\.inf$' -or $deviceId -notlike 'USB\VID_8087&PID_0A2A*' -or $backupInfs.Count -lt 1) {
    Write-Host 'HATA: Yedek dogrulama bilgileri gecersiz; otomatik islem yapilmadi.' -ForegroundColor Red
    exit 3
}

$current = @(Get-CimInstance Win32_PnPSignedDriver | Where-Object {
    $_.DeviceID -eq $deviceId
}) | Select-Object -First 1

if ($null -ne $current -and [string]$current.InfName -eq $originalInf) {
    Write-Host 'Bluetooth zaten asil Intel surucusunu kullaniyor.' -ForegroundColor Green
    exit 0
}

if ($null -ne $current) {
    $currentInf = [string]$current.InfName
    $currentProvider = [string]$current.DriverProviderName

    if ($currentInf -notmatch '^oem\d+\.inf$' -or $currentProvider -notmatch 'libwdi|WinUSB') {
        Write-Host 'HATA: Mevcut surucu beklenen Zadig/WinUSB surucusu degil.' -ForegroundColor Red
        Write-Host "Surucu: $currentInf / Saglayici: $currentProvider"
        Write-Host 'Guvenlik icin hicbir surucu silinmedi.'
        exit 4
    }

    Write-Host "Gecici WinUSB surucusu kaldiriliyor: $currentInf / $currentProvider"
    & pnputil.exe /delete-driver $currentInf /uninstall /force
    if ($LASTEXITCODE -ne 0) {
        Write-Host 'HATA: WinUSB surucusu kaldirilamadi. Bilgisayari yeniden baslatip tekrar deneyin.' -ForegroundColor Red
        exit 5
    }
}

Write-Host 'Yedek Intel Bluetooth surucusu yukleniyor...'
foreach ($inf in $backupInfs) {
    & pnputil.exe /add-driver $inf.FullName /install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "UYARI: Bu INF yuklenemedi: $($inf.FullName)" -ForegroundColor Yellow
    }
}

& pnputil.exe /scan-devices | Out-Host
Start-Sleep -Seconds 3

$restored = @(Get-CimInstance Win32_PnPSignedDriver | Where-Object {
    $_.DeviceID -like 'USB\VID_8087&PID_0A2A*'
}) | Select-Object -First 1

if ($null -ne $restored -and [string]$restored.DriverProviderName -notmatch 'libwdi|WinUSB') {
    Write-Host ''
    Write-Host 'BLUETOOTH GERI YUKLENDI' -ForegroundColor Green
    Write-Host "Surucu: $($restored.InfName) / $($restored.DriverProviderName) / $($restored.DriverVersion)"
    Write-Host 'Bluetooth simgesi hemen gelmezse Windowsu bir kez yeniden baslatin.'
    exit 0
}

Write-Host ''
Write-Host 'Geri yukleme tamamlanamadi.' -ForegroundColor Red
Write-Host 'Bilgisayari yeniden baslatin ve bu dosyayi bir kez daha yonetici olarak calistirin.'
Write-Host "Yedek klasoru: $backupDir"
exit 6

