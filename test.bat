@echo off
setlocal enabledelayedexpansion

set EXE_PATH=EIFGENs\simplexeiffel\W_code\simplexeiffel.exe
set INPUT_DIR=problems
set OUTPUT_DIR=solutions

if not exist "%EXE_PATH%" (
    echo [ERROR] File %EXE_PATH% not found!
    pause
    exit /b
)
if not exist "%OUTPUT_DIR%" (
    mkdir "%OUTPUT_DIR%"
)

echo ==========================================
echo Starting SimplexEiffel Tests (Real & Integer)
echo ==========================================

for %%f in (%INPUT_DIR%\*.txt) do (
    set "FILENAME=%%~nf"
    echo [TESTING] %%f ...

    :: 1. REAL MODE
    type "%%f" | "%EXE_PATH%" > "%OUTPUT_DIR%\!FILENAME!_real.txt" 2>&1
    if !errorlevel! equ 0 (
        echo    -- Real mode: OK. Saved to !FILENAME!_real.txt
    ) else (
        echo    -- Real mode: ERROR.
    )

    :: 2. INTEGER MODE
    type "%%f" | "%EXE_PATH%" -i > "%OUTPUT_DIR%\!FILENAME!_integer.txt" 2>&1
    if !errorlevel! equ 0 (
        echo    -- Integer mode: OK. Saved to !FILENAME!_integer.txt
    ) else (
        echo    -- Integer mode: ERROR.
    )
    
    echo.
)

echo ==========================================
echo All tests finished.
echo ==========================================
pause