#requires -Version 5.1

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$readyMarker = Join-Path $root 'driver-backup\BACKUP_OK.txt'

if (-not (Test-Path $readyMarker)) {
    Write-Host 'HATA: Dogrulanmis Intel surucu yedegi yok.' -ForegroundColor Red
    Write-Host 'Once 1_SURUCU_YEDEKLE.bat dosyasini yonetici olarak calistirin.'
    exit 1
}

$drivers = @(Get-CimInstance Win32_PnPSignedDriver | Where-Object {
    $_.DeviceID -like 'USB\VID_8087&PID_0A2A*'
})

if ($drivers.Count -ne 1) {
    Write-Host "HATA: 8087:0A2A aygiti icin tek bir surucu kaydi bulunamadi. Bulunan: $($drivers.Count)" -ForegroundColor Red
    exit 2
}

$driver = $drivers[0]
$provider = [string]$driver.DriverProviderName

if ($provider -notmatch 'libwdi|WinUSB') {
    Write-Host 'HATA: Intel Bluetooth aygiti henuz WinUSB kullanmiyor.' -ForegroundColor Red
    Write-Host "Mevcut saglayici: $provider"
    Write-Host 'README dosyasindaki Zadig adimini uygulayin; baska bir aygit secmeyin.'
    exit 3
}

$required = @(
    'CommunicatePars-iOS-Mouse.exe',
    'ibt-11-5.sfi',
    'ibt-11-5.ddc'
)

foreach ($file in $required) {
    if (-not (Test-Path (Join-Path $root $file))) {
        Write-Host "HATA: Gerekli dosya eksik: $file" -ForegroundColor Red
        exit 4
    }
}

Write-Host 'WinUSB ve surucu yedegi dogrulandi.' -ForegroundColor Green
Write-Host "Aygit: $($driver.DeviceName)"
Write-Host "Surucu: $($driver.InfName) / $provider"
exit 0
