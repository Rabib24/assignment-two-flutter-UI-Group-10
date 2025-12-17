#!/bin/bash
# verify_build.sh - Verify that all build fixes are properly applied

echo "============================================"
echo "MiniMart Build Verification Script"
echo "============================================"
echo

echo "[1/5] Checking pubspec.yaml versions..."
grep "cached_network_image:" pubspec.yaml | grep -q "3.4.1" && echo "✅ cached_network_image version correct" || echo "❌ cached_network_image version incorrect"
grep "flutter_cache_manager:" pubspec.yaml | grep -q "3.4.0" && echo "✅ flutter_cache_manager version correct" || echo "❌ flutter_cache_manager version incorrect"
echo

echo "[2/5] Checking gradle.properties..."
grep -q "org.gradle.warning.mode=none" android/gradle.properties && echo "✅ Deprecation warnings suppressed" || echo "❌ Deprecation warnings not suppressed"
grep -q "org.gradle.caching=true" android/gradle.properties && echo "✅ Gradle caching enabled" || echo "❌ Gradle caching not enabled"
echo

echo "[3/5] Checking build script..."
test -f build.bat && echo "✅ build.bat script exists" || echo "❌ build.bat script missing"
echo

echo "[4/5] Checking dependencies..."
flutter pub get > /dev/null 2>&1 && echo "✅ Dependencies resolved successfully" || echo "❌ Dependency resolution failed"
echo

echo "[5/5] Running flutter analyze..."
flutter analyze > /dev/null 2>&1 && echo "✅ Static analysis passed" || echo "❌ Static analysis failed"
echo

echo "============================================"
echo "Verification Complete!"
echo "============================================"