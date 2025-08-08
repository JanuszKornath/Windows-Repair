@echo off
chcp 65001 >nul
pushd %~dp0
title Systemüberprüfung mit DISM und SFC
color 1F

:: Funktion für erklärende Pause
:PauseMitText
echo %~1
pause >nul
goto :eof

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
set LOG=SystemCheck.log
echo === Systemcheck gestartet: %DATE% %TIME% === > "%LOG%"

echo =============================
echo   Windows Systemprüfung
echo =============================
echo.

echo [1/4] DISM: CheckHealth wird ausgeführt...
Dism /Online /Cleanup-Image /CheckHealth >> "%LOG%" 2>&1
if %errorlevel% neq 0 (
    echo Fehler bei CheckHealth. Details siehe "%LOG%".
    call :PauseMitText "Taste drücken, um den Fehlerbericht zu sehen..."
    exit /b
)
call :PauseMitText "CheckHealth abgeschlossen. Taste drücken, um fortzufahren..."

echo [2/4] DISM: ScanHealth wird ausgeführt...
Dism /Online /Cleanup-Image /ScanHealth >> "%LOG%" 2>&1
if %errorlevel% neq 0 (
    echo Fehler bei ScanHealth. Details siehe "%LOG%".
    call :PauseMitText "Taste drücken, um den Fehlerbericht zu sehen..."
    exit /b
)
call :PauseMitText "ScanHealth abgeschlossen. Taste drücken, um fortzufahren..."

echo [3/4] DISM: RestoreHealth wird ausgeführt...
Dism /Online /Cleanup-Image /RestoreHealth >> "%LOG%" 2>&1
if %errorlevel% neq 0 (
    echo Fehler bei RestoreHealth. Details siehe "%LOG%".
    call :PauseMitText "Taste drücken, um den Fehlerbericht zu sehen..."
    exit /b
)
call :PauseMitText "RestoreHealth abgeschlossen. Taste drücken, um fortzufahren..."

echo [4/4] SFC: Systemdatei-Überprüfung wird ausgeführt...
sfc /scannow >> "%LOG%" 2>&1
if %errorlevel% neq 0 (
    echo Fehler bei SFC. Details siehe "%LOG%".
    call :PauseMitText "Taste drücken, um den Fehlerbericht zu sehen..."
    exit /b
)
call :PauseMitText "SFC abgeschlossen. Taste drücken, um zum Abschlussbericht zu gehen..."

echo =============================
echo     Vorgang abgeschlossen
echo =============================
echo Siehe Logdatei: "%LOG%"
echo.
echo Letzte Einträge aus der Logdatei:
type "%LOG%" | more
call :PauseMitText "Taste drücken, um das Fenster zu schließen..."
exit
