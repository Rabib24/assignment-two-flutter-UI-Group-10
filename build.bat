@echo off
echo ============================================
echo MiniMart Flutter Build Script
echo ============================================
echo.

echo [1/4] Cleaning build cache...
call flutter clean
if %errorlevel% neq 0 goto :error

echo.
echo [2/4] Getting dependencies...
call flutter pub get
if %errorlevel% neq 0 goto :error

echo.
echo [3/4] Upgrading packages...
call flutter pub upgrade --major-versions
if %errorlevel% neq 0 goto :error

echo.
echo [4/4] Running app...
call flutter run
if %errorlevel% neq 0 goto :error

goto :success

:error
echo.
echo ============================================
echo BUILD FAILED!
echo ============================================
pause
exit /b 1

:success
echo.
echo ============================================
echo BUILD SUCCESSFUL!
echo ============================================