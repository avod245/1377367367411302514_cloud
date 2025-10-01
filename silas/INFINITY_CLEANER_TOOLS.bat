@echo off
chcp 65001 >nul
color 0D
title TOOLS CLEANER HELPER 
mode con cols=80 lines=30

:: Menu principal
:MENU
cls
echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                 INFINITY TOOLS CLEANER HELPER                ║
echo ╠══════════════════════════════════════════════════════════════╣
echo ║                                                              ║
echo ║   [1] Nettoyer les fichiers du jeu                           ║
echo ║   [2] (Beta) Soft Spoof Hwid                                 ║
echo ║   [3] Quitter                                                ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.
set /p choix= Fais ton choix [1-3] : 

if "%choix%"=="1" goto CLEANCOD
if "%choix%"=="2" goto SOFTSPOOF
if "%choix%"=="3" exit
goto MENU


echo.
pause
goto MENU

:: ================= NETTOYAGE DES DONNES DU JEU =================
:CLEANCOD
cls
echo.
echo ==== SELECTION DE LA VERSION COD ====
echo.
echo [1] Steam
echo [2] Battle.net
echo [3] Xbox
echo [0] Retour
echo.
set /p version=Choix :

if "%version%"=="1" goto clean_steam
if "%version%"=="2" goto clean_bnet
if "%version%"=="3" goto clean_xbox
if "%version%"=="0" goto menu
goto clean_menu

:common_clean
echo.
echo [CLEAN] Suppression fichiers Windows...
del /f /s /q "%TEMP%\*" >nul 2>&1
del /f /s /q "%WINDIR%\Prefetch\*" >nul 2>&1
del /f /s /q "%APPDATA%\Microsoft\Windows\Recent\*" >nul 2>&1

echo [CLEAN] Suppression des .log / .bak / .json...
for %%F in ("*.log" "*.bak" "*.json" "*.dmp") do (
  del /s /f /q "%USERPROFILE%\AppData\Local\%%F" >nul 2>&1
)

goto menu

:clean_steam
echo.
echo [INFO] Nettoyage version Steam...
taskkill /f /im steam.exe >nul 2>&1
rmdir /s /q "%USERPROFILE%\Documents\Call of Duty" >nul 2>&1
rmdir /s /q "%LOCALAPPDATA%\Activision" >nul 2>&1
rmdir /s /q "%APPDATA%\Activision" >nul 2>&1
goto common_clean

:clean_bnet
echo.
echo [INFO] Nettoyage version Battle.net...
taskkill /f /im Battle.net.exe >nul 2>&1
taskkill /f /im Agent.exe >nul 2>&1
rmdir /s /q "%PROGRAMDATA%\Battle.net" >nul 2>&1
rmdir /s /q "%PROGRAMDATA%\Blizzard Entertainment" >nul 2>&1
rmdir /s /q "%APPDATA%\Battle.net" >nul 2>&1
rmdir /s /q "%LOCALAPPDATA%\Battle.net" >nul 2>&1
goto common_clean

:clean_xbox
echo.
echo [INFO] Nettoyage version Xbox...
rmdir /s /q "%LOCALAPPDATA%\Packages\Microsoft.COD*" >nul 2>&1
rmdir /s /q "%LOCALAPPDATA%\Packages\Microsoft.Activision*" >nul 2>&1
goto common_clean

:SOFTSPOOF
cls
echo.
echo ===== (BETA) SOFT SPOOF HWID =====

:: Spoof MAC
echo [SPOOF] MAC address...
powershell -Command "Get-NetAdapter -Physical | Where-Object {$_.Status -eq 'Up'} | ForEach-Object { Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName 'Network Address' -DisplayValue ((Get-Random -Minimum 100000000000 -Maximum 999999999999).ToString()) }" >nul 2>&1

:: Spoof VolumeID
echo [SPOOF] VolumeID (C:)...
powershell -Command "$newID = -join ((48..57) + (65..70) | Get-Random -Count 8 | ForEach-Object {[char]$_}); Set-ItemProperty -Path 'HKLM\SYSTEM\MountedDevices' -Name '\DosDevices\C:' -Value ([byte[]](0x5C,0x00,0x3F,0x00,0x3F,0x00,0x5C,0x00,0x56,0x00,0x4F,0x00,0x4C,0x00,0x31,0x00))" >nul 2>&1

:: Spoof ProductID
echo [SPOOF] ProductID Windows...
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v "ProductId" /t REG_SZ /d "12345-67890-13337-AAOEM" /f >nul

:: New Machine GUID
echo [SPOOF] Machine GUID...
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography" /v "MachineGuid" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography" /v "MachineGuid" /t REG_SZ /d "%RANDOM%%RANDOM%%RANDOM%" /f >nul

:: Supprimer les logs Activision + Battle.net
rmdir /s /q "%USERPROFILE%\Documents\Call of Duty" >nul 2>&1
rmdir /s /q "%LOCALAPPDATA%\Activision" >nul 2>&1
rmdir /s /q "%APPDATA%\Battle.net" >nul 2>&1
rmdir /s /q "%PROGRAMDATA%\Battle.net" >nul 2>&1
rmdir /s /q "%PROGRAMDATA%\Blizzard Entertainment" >nul 2>&1

:: Suppression des caches Windows
del /f /s /q "%TEMP%\*" >nul 2>&1
del /f /s /q "%WINDIR%\Prefetch\*" >nul 2>&1

:: Changement de l'adresse MAC (aléatoire)
echo [SPOOF] Changement MAC...
getmac >nul
for /f "tokens=1 delims=:" %%a in ('getmac ^| findstr /v "Disconnected"') do (
  set "adapter=%%a"
  goto :change_mac
)
::change_mac
powershell -Command "Get-NetAdapter -Name '*Ethernet*','*Wi-Fi*' | Set-NetAdapterAdvancedProperty -DisplayName 'Network Address' -DisplayValue ((Get-Random -Minimum 100000000000 -Maximum 999999999999).ToString())" >nul 2>&1

:: Reset IP / DNS
ipconfig /flushdns >nul
netsh winsock reset >nul
netsh int ip reset >nul

echo [OK] Spoof terminé. Redémarrage requis pour effet complet.
pause
exit
