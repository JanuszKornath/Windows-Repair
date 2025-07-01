@echo off
title Systemüberprüfung mit DISM und SFC
color 1F

echo =============================
echo   Windows Systemprüfung
echo =============================
echo.

echo [1/4] DISM: CheckHealth wird ausgeführt...
Dism /Online /Cleanup-Image /CheckHealth
echo.
pause

echo [2/4] DISM: ScanHealth wird ausgeführt...
Dism /Online /Cleanup-Image /ScanHealth
echo.
pause

echo [3/4] DISM: RestoreHealth wird ausgeführt...
Dism /Online /Cleanup-Image /RestoreHealth
echo.
pause

echo [4/4] SFC: Systemdatei-Überprüfung wird ausgeführt...
sfc /scannow
echo.
pause

echo =============================
echo     Vorgang abgeschlossen
echo =============================
pause
exit
