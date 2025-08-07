@echo off
pushd %~dp0
chcp 1252 >nul
title Systemüberprüfung mit DISM und SFC
color 1F

:: Admin-Rechte prüfen (zuverlässig)
fltmc >nul 2>&1
if %errorlevel% neq 0 (
    echo [FEHLER] Bitte als Administrator ausfuehren!
    pause
    exit /b
)

:: Logdatei initialisieren
set LOG=SystemCheck.log
echo === Systemcheck gestartet: %DATE% %TIME% === > %LOG%

echo =============================
echo   Windows Systemprüfung
echo =============================
echo.

echo [1/4] DISM: CheckHealth wird ausgeführt...
Dism /Online /Cleanup-Image /CheckHealth >> %LOG% 2>&1
if %errorlevel% neq 0 (
    echo Fehler bei CheckHealth. Details siehe %LOG%.
    pause
    exit /b
)
echo.
pause

echo [2/4] DISM: ScanHealth wird ausgeführt...
Dism /Online /Cleanup-Image /ScanHealth >> %LOG% 2>&1
if %errorlevel% neq 0 (
    echo Fehler bei ScanHealth. Details siehe %LOG%.
    pause
    exit /b
)
echo.
pause

echo [3/4] DISM: RestoreHealth wird ausgeführt...
Dism /Online /Cleanup-Image /RestoreHealth >> %LOG% 2>&1
if %errorlevel% neq 0 (
    echo Fehler bei RestoreHealth. Details siehe %LOG%.
    pause
    exit /b
)
echo.
pause

echo [4/4] SFC: Systemdatei-Überprüfung wird ausgeführt...
sfc /scannow >> %LOG% 2>&1
if %errorlevel% neq 0 (
    echo Fehler bei SFC. Details siehe %LOG%.
    pause
    exit /b
)
echo.
pause

echo =============================
echo     Vorgang abgeschlossen
echo =============================
echo Siehe Logdatei: %LOG%
pause
exit