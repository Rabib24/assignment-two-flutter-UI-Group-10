@echo off
set ANDROID_HOME=C:\Users\AC\AppData\Local\Android\Sdk
set PATH=%PATH%;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\tools;%ANDROID_HOME%\tools\bin
set JAVA_OPTS=-XX:-UseVMInterruptibleIO
echo Environment variables set. Running Flutter app...
flutter run