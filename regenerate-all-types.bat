@echo off
REM Batch script to regenerate all types (Prisma + Dart)
REM Run with: regenerate-all-types.bat

setlocal enabledelayedexpansion
cd /d "%~dp0"

echo.
echo ================================
echo Regenerating All Project Types
echo ================================
echo.

REM ========== Backend (Prisma) ==========
echo [1/2] Regenerating Backend (Prisma) types...
cd server
call npx prisma generate
if errorlevel 1 (
    echo ERROR: Failed to regenerate Prisma types
    exit /b 1
)
echo SUCCESS: Prisma types regenerated!
echo.

REM ========== Frontend (Flutter/Dart) ==========
echo [2/2] Regenerating Frontend (Dart) code...
cd ..\flutter_app
call dart run build_runner build --delete-conflicting-outputs
if errorlevel 1 (
    echo ERROR: Failed to regenerate Dart code
    exit /b 1
)
echo SUCCESS: Dart code regenerated!
echo.

cd ..
echo ================================
echo All types regenerated successfully!
echo ================================
echo.
echo Next steps:
echo   1. Restart your IDE or language servers
echo   2. TypeScript: Ctrl+Shift+P ^> "TypeScript: Restart TS Server"
echo   3. Dart: Ctrl+Shift+P ^> "Dart: Restart Analysis Server"
echo.

endlocal
