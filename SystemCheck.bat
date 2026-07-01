@echo off
setlocal enabledelayedexpansion
chcp 1252 >nul
cd /d "%~dp0"
title Systempruefung mit DISM und SFC
color 1F
goto :main

:: -------------------------------------
:: Funktion für erklärende Pausen
:PauseMitText
if not "%~1"=="" echo %~1
pause >nul
goto :eof
:: -------------------------------------

:main
:: Admin-Rechte prüfen
fltmc >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo [FEHLER] Bitte als Administrator ausführen!
    color 1F
    call :PauseMitText "Taste drücken, um das Fenster zu schließen..."
    exit /b
)

:: Logdatei initialisieren
set "LOG=%~dp0SystemCheck.log"
echo === Systemcheck gestartet: %DATE% %TIME% === > "%LOG%"

echo =============================
echo   Windows Systemprüfung
echo =============================
echo.

:: Fehlerüberwachung aktivieren
set "FAIL=0"

echo [1/4] DISM: CheckHealth wird ausgeführt...
powershell -NoProfile -Command "& { dism /Online /Cleanup-Image /CheckHealth 2>&1 | Tee-Object -FilePath $env:LOG -Append; exit $LASTEXITCODE }"
if %errorlevel% neq 0 set FAIL=1
if !FAIL! neq 0 goto :Fehler
call :PauseMitText "CheckHealth abgeschlossen. Taste drücken, um fortzufahren..."

echo [2/4] DISM: ScanHealth wird ausgeführt...
powershell -NoProfile -Command "& { dism /Online /Cleanup-Image /ScanHealth 2>&1 | Tee-Object -FilePath $env:LOG -Append; exit $LASTEXITCODE }"
if %errorlevel% neq 0 set FAIL=2
if !FAIL! neq 0 goto :Fehler
call :PauseMitText "ScanHealth abgeschlossen. Taste drücken, um fortzufahren..."

echo [3/4] DISM: RestoreHealth wird ausgeführt...
powershell -NoProfile -Command "& { dism /Online /Cleanup-Image /RestoreHealth 2>&1 | Tee-Object -FilePath $env:LOG -Append; exit $LASTEXITCODE }"
if %errorlevel% neq 0 set FAIL=3
if !FAIL! neq 0 goto :Fehler
call :PauseMitText "RestoreHealth abgeschlossen. Taste drücken, um fortzufahren..."

echo [4/4] SFC: Systemdatei-Überprüfung wird ausgeführt...
powershell -NoProfile -Command "& { sfc /scannow 2>&1 | Tee-Object -FilePath $env:LOG -Append; exit $LASTEXITCODE }"
if %errorlevel% neq 0 set FAIL=4
if !FAIL! neq 0 goto :Fehler
call :PauseMitText "SFC abgeschlossen. Taste drücken, um zum Abschlussbericht zu gehen..."

:: Erfolgreicher Abschluss
echo =============================
echo     Vorgang abgeschlossen
echo =============================
echo Siehe Logdatei: "%LOG%"
echo.
echo Letzte Einträge aus der Logdatei:
type "%LOG%" | more
goto :Ende

:Fehler
color 0C
echo [FEHLER] Schritt !FAIL! ist fehlgeschlagen. Siehe "%LOG%" für Details.
color 1F
goto :Ende

:Ende
call :PauseMitText "Taste drücken, um das Fenster zu schließen..."
exit
