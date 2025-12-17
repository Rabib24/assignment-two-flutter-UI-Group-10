# Set environment variables
$env:ANDROID_HOME = "C:\Users\AC\AppData\Local\Android\Sdk"
$env:PATH += ";$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\tools;$env:ANDROID_HOME\tools\bin"
$env:JAVA_OPTS = "-XX:-UseVMInterruptibleIO"

# Create temp directory if it doesn't exist
if (!(Test-Path "C:\temp")) {
    New-Item -ItemType Directory -Path "C:\temp"
}

# Run Flutter app
Write-Host "Environment variables set. Running Flutter app..."
flutter run