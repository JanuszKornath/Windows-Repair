@echo off
setlocal enabledelayedexpansion
chcp 1252 >nul
cd /d "%~dp0"
title Systempruefung mit DISM und SFC
color 1F
goto :main

:PauseMitText
if not "%~1"=="" echo %~1
pause >nul
goto :eof

:main
:: Admin-Rechte pruefen
fltmc >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo [FEHLER] Bitte als Administrator ausfuehren!
    color 1F
    call :PauseMitText "Taste druecken, um das Fenster zu schliessen..."
    exit /b
)

:: Logdatei initialisieren
set LOG=SystemCheck.log
echo === Systemcheck gestartet: %DATE% %TIME% === > "%LOG%"

echo =============================
echo   Windows Systempruefung
echo =============================
echo.

:: Fehlerüberwachung aktivieren
set "FAIL=0"

echo [1/4] DISM: CheckHealth wird ausgefuehrt...
Dism /Online /Cleanup-Image /CheckHealth >> "%LOG%" 2>&1 || set FAIL=1
if !FAIL! neq 0 goto :Fehler

echo [2/4] DISM: ScanHealth wird ausgefuehrt...
Dism /Online /Cleanup-Image /ScanHealth >> "%LOG%" 2>&1 || set FAIL=2
if !FAIL! neq 0 goto :Fehler

echo [3/4] DISM: RestoreHealth wird ausgefuehrt...
Dism /Online /Cleanup-Image /RestoreHealth >> "%LOG%" 2>&1 || set FAIL=3
if !FAIL! neq 0 goto :Fehler

echo [4/4] SFC: Systemdatei-Ueberpruefung wird ausgefuehrt...
sfc /scannow >> "%LOG%" 2>&1 || set FAIL=4
if !FAIL! neq 0 goto :Fehler

:: Erfolgreicher Abschluss
echo =============================
echo     Vorgang abgeschlossen
echo =============================
echo Siehe Logdatei: "%LOG%"
echo.
echo Letzte Eintraege aus der Logdatei:
type "%LOG%" | more
goto :Ende

:Fehler
color 0C
echo [FEHLER] Schritt !FAIL! ist fehlgeschlagen. Siehe "%LOG%" fuer Details.
color 1F
goto :Ende

:Ende
call :PauseMitText "Taste druecken, um das Fenster zu schliessen..."
exit /b