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
    Write-Host '1_SURUCU_YEDEKLE.bat dosyasina sag tiklayip "Yonetici olarak calistir" secin.'
    exit 1
}

if (Test-Path $readyMarker) {
    Write-Host 'YEDEK HAZIR: Daha once olusturulmus ve korunuyor.' -ForegroundColor Green
    Write-Host "Konum: $backupDir"
    exit 0
}

$drivers = @(Get-CimInstance Win32_PnPSignedDriver | Where-Object {
    $_.DeviceID -like 'USB\VID_8087&PID_0A2A*'
})

if ($drivers.Count -ne 1) {
    Write-Host "HATA: 8087:0A2A icin tam bir surucu kaydi bulunamadi. Bulunan: $($drivers.Count)" -ForegroundColor Red
    Write-Host 'Zadig ile hicbir surucuyu degistirmeyin.'
    exit 2
}

$driver = $drivers[0]
$infName = [string]$driver.InfName
$deviceId = [string]$driver.DeviceID

if ($infName -notmatch '^oem\d+\.inf$') {
    Write-Host "HATA: Beklenen Intel OEM surucu paketi bulunamadi: $infName" -ForegroundColor Red
    Write-Host 'Zadig ile hicbir surucuyu degistirmeyin.'
    exit 3
}

New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

$metadata = [ordered]@{
    BackupTimeUtc     = (Get-Date).ToUniversalTime().ToString('o')
    DeviceName        = [string]$driver.DeviceName
    DeviceID          = $deviceId
    Manufacturer      = [string]$driver.Manufacturer
    DriverProvider    = [string]$driver.DriverProviderName
    DriverVersion     = [string]$driver.DriverVersion
    OriginalInfName   = $infName
}

$metadata | ConvertTo-Json | Out-File (Join-Path $backupDir 'original-driver.json') -Encoding utf8
$infName | Out-File (Join-Path $backupDir 'original-inf.txt') -Encoding ascii
$deviceId | Out-File (Join-Path $backupDir 'device-id.txt') -Encoding ascii

Write-Host "Yedekleniyor: $($driver.DeviceName) / $infName"
& pnputil.exe /export-driver $infName $backupDir
if ($LASTEXITCODE -ne 0) {
    Write-Host 'HATA: pnputil surucu paketini disari aktaramadi.' -ForegroundColor Red
    Write-Host 'Zadig ile hicbir surucuyu degistirmeyin.'
    exit 4
}

$exportedInf = @(Get-ChildItem -Path $backupDir -Recurse -Filter '*.inf' -File)
if ($exportedInf.Count -lt 1) {
    Write-Host 'HATA: Yedek klasorunde INF dosyasi bulunamadi.' -ForegroundColor Red
    Write-Host 'Zadig ile hicbir surucuyu degistirmeyin.'
    exit 5
}

@(
    'CommunicatePars Intel Bluetooth driver backup is complete.'
    "Original INF: $infName"
    "Device ID: $deviceId"
) | Out-File $readyMarker -Encoding ascii

Write-Host ''
Write-Host 'YEDEK HAZIR' -ForegroundColor Green
Write-Host "Aygit: $($driver.DeviceName)"
Write-Host "Kimlik: $deviceId"
Write-Host "Surucu: $infName / $($driver.DriverVersion)"
Write-Host "Konum: $backupDir"
Write-Host ''
Write-Host 'Yalnizca bu mesaj gorulduyse README dosyasindaki Zadig adimina gecebilirsiniz.'

