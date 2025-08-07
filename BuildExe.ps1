# BuildExe.ps1 (ASCII-safe version)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
Write-Host "[OK] Temporäre ExecutionPolicy auf Bypass gesetzt." -ForegroundColor Green

try {
    Import-Module ps2exe -Force -ErrorAction Stop
    Write-Host "[OK] Modul ps2exe erfolgreich geladen." -ForegroundColor Green
} catch {
    Write-Host "[X] Modul ps2exe konnte nicht geladen werden." -ForegroundColor Red
    Write-Host "Tipp: Installiere es ggf. mit: Install-Module ps2exe -Scope CurrentUser"
    exit 1
}

$scriptPath = Join-Path $PSScriptRoot 'SystemCheckGUI.ps1'
$exePath    = Join-Path $PSScriptRoot 'SystemCheckGUI.exe'

if (-not (Test-Path $scriptPath)) {
    Write-Host "[X] Das Skript '$scriptPath' wurde nicht gefunden." -ForegroundColor Red
    exit 1
}

Write-Host "[...] Kompiliere '$scriptPath' zu EXE..." -ForegroundColor Cyan

try {
    Invoke-PS2EXE -InputFile $scriptPath -OutputFile $exePath -noConsole -noOutput -ErrorAction Stop
    Write-Host "[OK] EXE erfolgreich erstellt: $exePath" -ForegroundColor Green
} catch {
    Write-Host "[X] Fehler beim Erstellen der EXE: $_" -ForegroundColor Red
    exit 1
}
