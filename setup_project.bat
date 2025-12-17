@echo off
echo MiniMart Project Setup Script
echo =============================
echo This script will help you set up the MiniMart project quickly.
echo.

REM Check if Flutter is installed
echo Checking Flutter installation...
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Flutter is not installed or not in PATH
    echo Please install Flutter first and try again
    pause
    exit /b 1
)

echo Flutter is installed. Proceeding with setup...
echo.

REM Get packages
echo Getting Flutter packages...
flutter pub get
if %errorlevel% neq 0 (
    echo Error: Failed to get packages
    pause
    exit /b 1
)

echo.
echo Packages downloaded successfully!
echo.

REM Check if firebase_options.dart exists
if not exist "lib\firebase_options.dart" (
    echo Firebase configuration file not found.
    echo.
    echo Please follow these steps:
    echo 1. Rename 'lib\firebase_options_template.dart' to 'lib\firebase_options.dart'
    echo 2. Open the file and replace placeholder values with your Firebase project configuration
    echo 3. For detailed instructions, see SETUP.md
    echo.
    echo NOTE: You need to create a Firebase project at https://console.firebase.google.com
    echo.
) else (
    echo Firebase configuration file found.
    echo.
)

echo Setup completed!
echo.
echo To run the project:
echo flutter run
echo.
echo For web:
echo flutter run -d chrome
echo.
pause