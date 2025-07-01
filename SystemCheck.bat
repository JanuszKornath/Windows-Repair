@echo off
chcp 1252 >nul
title Systemüberprüfung mit DISM und SFC
color 1F

echo =============================
echo   Windows Systempruefung
echo =============================
echo.

echo [1/4] DISM: CheckHealth wird ausgefuehrt...
Dism /Online /Cleanup-Image /CheckHealth
echo.
pause

echo [2/4] DISM: ScanHealth wird ausgefuehrt...
Dism /Online /Cleanup-Image /ScanHealth
echo.
pause

echo [3/4] DISM: RestoreHealth wird ausgefuehrt...
Dism /Online /Cleanup-Image /RestoreHealth
echo.
pause

echo [4/4] SFC: Systemdatei-Ueberpruefung wird ausgefuehrt...
sfc /scannow
echo.
pause

echo =============================
echo     Vorgang abgeschlossen
echo =============================
pause
exit
