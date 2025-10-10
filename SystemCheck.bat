@echo off
chcp 1252 >nul
cd /d "%~dp0"
title Systempruefung mit DISM und SFC
color 1F

:: Funktion fuer erklaerende Pause
:PauseMitText
echo %~1
pause >nul
goto :eof

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

echo [1/4] DISM: CheckHealth wird ausgefuehrt...
Dism /Online /Cleanup-Image /CheckHealth >> "%LOG%" 2>&1
if %errorlevel% neq 0 (
    echo Fehler bei CheckHealth. Details siehe "%LOG%".
    call :PauseMitText "Taste druecken, um den Fehlerbericht zu sehen..."
    exit /b
)
call :PauseMitText "CheckHealth abgeschlossen. Taste druecken, um fortzufahren..."

echo [2/4] DISM: ScanHealth wird ausgefuehrt...
Dism /Online /Cleanup-Image /ScanHealth >> "%LOG%" 2>&1
if %errorlevel% neq 0 (
    echo Fehler bei ScanHealth. Details siehe "%LOG%".
    call :PauseMitText "Taste druecken, um den Fehlerbericht zu sehen..."
    exit /b
)
call :PauseMitText "ScanHealth abgeschlossen. Taste druecken, um fortzufahren..."

echo [3/4] DISM: RestoreHealth wird ausgefuehrt...
Dism /Online /Cleanup-Image /RestoreHealth >> "%LOG%" 2>&1
if %errorlevel% neq 0 (
    echo Fehler bei RestoreHealth. Details siehe "%LOG%".
    call :PauseMitText "Taste druecken, um den Fehlerbericht zu sehen..."
    exit /b
)
call :PauseMitText "RestoreHealth abgeschlossen. Taste druecken, um fortzufahren..."

echo [4/4] SFC: Systemdatei-Ueberpruefung wird ausgefuehrt...
sfc /scannow >> "%LOG%" 2>&1
if %errorlevel% neq 0 (
    echo Fehler bei SFC. Details siehe "%LOG%".
    call :PauseMitText "Taste druecken, um den Fehlerbericht zu sehen..."
    exit /b
)
call :PauseMitText "SFC abgeschlossen. Taste druecken, um zum Abschlussbericht zu gehen..."

echo =============================
echo     Vorgang abgeschlossen
echo =============================
echo Siehe Logdatei: "%LOG%"
echo.
echo Letzte Eintraege aus der Logdatei:
type "%LOG%" | more
call :PauseMitText "Taste druecken, um das Fenster zu schliessen..."
exit