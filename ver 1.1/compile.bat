@echo off
setlocal
pushd "%~dp0"

rem Remove obsolete EasySD artifacts left by older cf-port builds.
del /q EasySD_MB.bin EasySD_EL.bin EasySD_MB.lst EasySD_EL.lst 2>nul
del /q EasySD_MB_BIN.tap EasySD_EL.tap EasySD.sna 2>nul

echo.
echo ========================================
echo   Building EasyCF for MB03+
echo ========================================
del /q EasyCF_MB.bin EasyCF_MB.lst 2>nul
sjasmplus --lst=EasyCF_MB.lst --raw=EasyCF_MB.bin easyhdd.a80
if errorlevel 1 goto :error_mb
if not exist EasyCF_MB.bin goto :missing_mb

echo.
echo ========================================
echo   Building EasyCF for eLeMeNt
echo ========================================
del /q EasyCF_EL.bin EasyCF_EL.lst 2>nul
sjasmplus --lst=EasyCF_EL.lst --define ELEMENT --raw=EasyCF_EL.bin easyhdd.a80
if errorlevel 1 goto :error_el
if not exist EasyCF_EL.bin goto :missing_el

echo.
echo ========================================
echo   Building TAP files
echo ========================================
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0make_taps.ps1"
if errorlevel 1 goto :error_taps

echo.
echo ========================================
echo   BUILD OK
echo ========================================
echo   EasyCF_MB.bin      - MB03+
echo   EasyCF_EL.bin      - eLeMeNt
echo   EasyCF_MB_BIN.tap  - simple TAP: LOAD 32768 / USR 32768
echo   EasyCF_EL.tap      - full eLeMeNt startup TAP
echo   EasyCF_MB.lst
echo   EasyCF_EL.lst
echo ========================================

popd
exit /b 0

:error_mb
echo.
echo *** MB03+ BUILD FAILED ***
goto :fail

:error_el
echo.
echo *** eLeMeNt BUILD FAILED ***
goto :fail

:error_taps
echo.
echo *** TAP BUILD FAILED ***
goto :fail

:missing_mb
echo.
echo *** MB03+ BUILD DID NOT CREATE EasyCF_MB.bin ***
goto :fail

:missing_el
echo.
echo *** eLeMeNt BUILD DID NOT CREATE EasyCF_EL.bin ***
goto :fail

:fail
popd
exit /b 1
