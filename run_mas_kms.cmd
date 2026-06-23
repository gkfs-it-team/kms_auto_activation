@echo off
setlocal enabledelayedexpansion

cd /d %TEMP%
set "R_FILE=C:\Windows\kms_report.txt"

echo [%date% %time%] Activation started > "%R_FILE%"

timeout /t 20 /nobreak >nul

:: ==============================================================================
:: 1. WINDOWS ACTIVATION
:: ==============================================================================
echo [%date% %time%] Activating Windows... >> "%R_FILE%"
%SystemRoot%\System32\cscript.exe //nologo %SystemRoot%\System32\slmgr.vbs /ipk M7XTQ-FN8P6-TTKYV-9D4CC-J462D >nul 2>&1
%SystemRoot%\System32\cscript.exe //nologo %SystemRoot%\System32\slmgr.vbs /skms kms8.msguides.com >nul 2>&1
%SystemRoot%\System32\cscript.exe //nologo %SystemRoot%\System32\slmgr.vbs /ato >> "%R_FILE%" 2>&1

:: ==============================================================================
:: 2. OFFICE 2010 ACTIVATION
:: ==============================================================================
echo [%date% %time%] Checking for Office 2010... >> "%R_FILE%"

set "OFFICE14_VBS_PATH="
if exist "C:\Program Files\Microsoft Office\Office14\ospp.vbs"       set "OFFICE14_VBS_PATH=C:\Program Files\Microsoft Office\Office14"
if exist "C:\Program Files (x86)\Microsoft Office\Office14\ospp.vbs" set "OFFICE14_VBS_PATH=C:\Program Files (x86)\Microsoft Office\Office14"

if not "%OFFICE14_VBS_PATH%"=="" (
    echo [%date% %time%] Found Office 2010 in "%OFFICE14_VBS_PATH%". Activating... >> "%R_FILE%"
    cd /d "%OFFICE14_VBS_PATH%"
    
    :: Встановлення GVLK ключів для Office 2010 (Pro Plus та Standard)
    %SystemRoot%\System32\cscript.exe //nologo ospp.vbs /inpkey:V7QKV-R4W2W-63MQM-JV8KG-6XQFD >nul 2>&1
    %SystemRoot%\System32\cscript.exe //nologo ospp.vbs /inpkey:VYBBJ-TRJPB-QFQRF-QFT4D-H3GVB >nul 2>&1
    
    %SystemRoot%\System32\cscript.exe //nologo ospp.vbs /sethst:kms8.msguides.com >> "%R_FILE%" 2>&1
    %SystemRoot%\System32\cscript.exe //nologo ospp.vbs /act >> "%R_FILE%" 2>&1
    %SystemRoot%\System32\cscript.exe //nologo ospp.vbs /dstatus >> "%R_FILE%" 2>&1
) else (
    echo [%date% %time%] Office 2010 not found. Skipping. >> "%R_FILE%"
)

:: ==============================================================================
:: 3. OFFICE 2016/2019/2021 ACTIVATION
:: ==============================================================================
echo [%date% %time%] Starting modern Office activation... >> "%R_FILE%"

set "OFFICE_VBS_PATH="

if exist "C:\Program Files\Microsoft Office\Office16\ospp.vbs"             set "OFFICE_VBS_PATH=C:\Program Files\Microsoft Office\Office16"
if exist "C:\Program Files (x86)\Microsoft Office\Office16\ospp.vbs"       set "OFFICE_VBS_PATH=C:\Program Files (x86)\Microsoft Office\Office16"
if exist "C:\Program Files\Microsoft Office\root\Office16\ospp.vbs"         set "OFFICE_VBS_PATH=C:\Program Files\Microsoft Office\root\Office16"
if exist "C:\Program Files (x86)\Microsoft Office\root\Office16\ospp.vbs"   set "OFFICE_VBS_PATH=C:\Program Files (x86)\Microsoft Office\root\Office16"

if not "%OFFICE_VBS_PATH%"=="" (
    echo [%date% %time%] Found ospp.vbs in "%OFFICE_VBS_PATH%". No conversion needed. >> "%R_FILE%"
    goto :ACTIVATE_OFFICE16
)

set "C2R_EXE=C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeClickToRun.exe"
if not exist "%C2R_EXE%" set "C2R_EXE=C:\Program Files (x86)\Common Files\microsoft shared\ClickToRun\OfficeClickToRun.exe"

if exist "%C2R_EXE%" (
    echo [%date% %time%] C2R found. Converting Retail to Volume... >> "%R_FILE%"
    "%C2R_EXE%" scenario=UniversalConfiguration OOD=1 platform=x86 culture=ru-ru ProductReleaseIds=ProPlus2021Volume >nul 2>&1
    "%C2R_EXE%" scenario=UniversalConfiguration OOD=1 platform=x64 culture=ru-ru ProductReleaseIds=ProPlus2021Volume >nul 2>&1
    timeout /t 15 /nobreak >nul
    if exist "C:\Program Files\Microsoft Office\root\Office16\ospp.vbs"       set "OFFICE_VBS_PATH=C:\Program Files\Microsoft Office\root\Office16"
    if exist "C:\Program Files (x86)\Microsoft Office\root\Office16\ospp.vbs" set "OFFICE_VBS_PATH=C:\Program Files (x86)\Microsoft Office\root\Office16"
)

if "%OFFICE_VBS_PATH%"=="" (
    echo [%date% %time%] ERROR: ospp.vbs not found. Modern Office missing or conversion failed. >> "%R_FILE%"
    goto :REPLACE_KMS
)

:ACTIVATE_OFFICE16
cd /d "%OFFICE_VBS_PATH%"
echo [%date% %time%] Installing KMS keys from: %OFFICE_VBS_PATH% >> "%R_FILE%"

%SystemRoot%\System32\cscript.exe //nologo ospp.vbs /inpkey:XQNVK-8JYDB-WJ9W3-YJ8YR-WFG99 >nul 2>&1
%SystemRoot%\System32\cscript.exe //nologo ospp.vbs /inpkey:FXYTK-NJJ8C-K84HY-VGW6V-GMT6T >nul 2>&1
%SystemRoot%\System32\cscript.exe //nologo ospp.vbs /sethst:kms8.msguides.com >> "%R_FILE%" 2>&1
%SystemRoot%\System32\cscript.exe //nologo ospp.vbs /act >> "%R_FILE%" 2>&1
%SystemRoot%\System32\cscript.exe //nologo ospp.vbs /dstatus >> "%R_FILE%" 2>&1

:: ==============================================================================
:: 4. REPLACE KMS WITH 10.0.0.10 (MAS 1.7 leavenonexistentkms)
:: ==============================================================================
:REPLACE_KMS
echo [%date% %time%] Applying leavenonexistentkms... >> "%R_FILE%"

set "SPPk=SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform"
set "OPPk=SOFTWARE\Microsoft\OfficeSoftwareProtectionPlatform"
set "_oApp=0ff1ce15-a989-479d-af46-f275c6370663"
set "_oApp2010=59a52881-a989-479d-af46-f275c6370663"

reg add "HKLM\%SPPk%" /f /v KeyManagementServiceName /t REG_SZ /d "10.0.0.10" >nul 2>&1
reg add "HKLM\%SPPk%" /f /v KeyManagementServicePort /t REG_SZ /d "1688" >nul 2>&1
reg delete "HKLM\%SPPk%" /f /v DisableDnsPublishing >nul 2>&1
reg delete "HKLM\%SPPk%" /f /v DisableKeyManagementServiceHostCaching >nul 2>&1

:: Fix for Modern Office
reg delete "HKLM\%SPPk%\%_oApp%" /f >nul 2>&1
reg add "HKLM\%SPPk%\%_oApp%" /f /v KeyManagementServiceName /t REG_SZ /d "10.0.0.10" >nul 2>&1
reg add "HKLM\%SPPk%\%_oApp%" /f /v KeyManagementServicePort /t REG_SZ /d "1688" >nul 2>&1
reg delete "HKLM\%SPPk%\%_oApp%" /f /reg:32 >nul 2>&1
reg add "HKLM\%SPPk%\%_oApp%" /f /v KeyManagementServiceName /t REG_SZ /d "10.0.0.10" /reg:32 >nul 2>&1
reg add "HKLM\%SPPk%\%_oApp%" /f /v KeyManagementServicePort /t REG_SZ /d "1688" /reg:32 >nul 2>&1

:: Fix for Office 2010
reg delete "HKLM\%SPPk%\%_oApp2010%" /f >nul 2>&1
reg add "HKLM\%SPPk%\%_oApp2010%" /f /v KeyManagementServiceName /t REG_SZ /d "10.0.0.10" >nul 2>&1
reg add "HKLM\%SPPk%\%_oApp2010%" /f /v KeyManagementServicePort /t REG_SZ /d "1688" >nul 2>&1
reg delete "HKLM\%SPPk%\%_oApp2010%" /f /reg:32 >nul 2>&1
reg add "HKLM\%SPPk%\%_oApp2010%" /f /v KeyManagementServiceName /t REG_SZ /d "10.0.0.10" /reg:32 >nul 2>&1
reg add "HKLM\%SPPk%\%_oApp2010%" /f /v KeyManagementServicePort /t REG_SZ /d "1688" /reg:32 >nul 2>&1

reg add "HKLM\%SPPk%" /f /v KeyManagementServiceName /t REG_SZ /d "10.0.0.10" /reg:32 >nul 2>&1
reg add "HKLM\%SPPk%" /f /v KeyManagementServicePort /t REG_SZ /d "1688" /reg:32 >nul 2>&1

reg delete "HKU\S-1-5-20\%SPPk%\%_oApp%" /f >nul 2>&1
reg delete "HKU\S-1-5-20\%SPPk%\%_oApp2010%" /f >nul 2>&1

reg add "HKLM\%OPPk%" /f /v KeyManagementServiceName /t REG_SZ /d "10.0.0.10" >nul 2>&1
reg delete "HKLM\%OPPk%" /f /v KeyManagementServicePort >nul 2>&1
reg delete "HKLM\%OPPk%" /f /v DisableDnsPublishing >nul 2>&1
reg delete "HKLM\%OPPk%" /f /v DisableKeyManagementServiceHostCaching >nul 2>&1
reg delete "HKLM\%OPPk%\%_oApp%" /f >nul 2>&1

echo [%date% %time%] Done. KMS replaced with 10.0.0.10 >> "%R_FILE%"

:EXIT_SCRIPT
echo [%date% %time%] Activation completed. >> "%R_FILE%"
exit /b 0