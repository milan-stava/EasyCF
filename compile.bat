@echo off
setlocal

echo.
echo ========================================
echo   Building EasySD for MB03+
echo ========================================
sjasmplus --lst --raw=EasySD_MB.bin easyhdd.a80
if errorlevel 1 (
    echo.
    echo *** MB03+ BUILD FAILED ***
    exit /b 1
)

echo.
echo ========================================
echo   Building EasySD for eLeMeNt
echo ========================================
sjasmplus --lst --define ELEMENT --raw=EasySD_EL.bin easyhdd.a80
if errorlevel 1 (
    echo.
    echo *** eLeMeNt BUILD FAILED ***
    exit /b 1
)

echo.
echo ========================================
echo   Building eLeMeNt TAP
echo ========================================
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0make_el_tap.ps1"
if errorlevel 1 (
    echo.
    echo *** eLeMeNt TAP BUILD FAILED ***
    exit /b 1
)

echo.
echo ========================================
echo   BUILD COMPLETE
echo ========================================
echo   EasySD_MB.bin
echo   EasySD_EL.bin
echo   EasySD_EL.tap
echo.

endlocal
