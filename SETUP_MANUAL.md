# MiniMart Flutter Application - Complete Setup & Run Manual

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Project Overview](#project-overview)
3. [Firebase Configuration](#firebase-configuration)
4. [Installation Steps](#installation-steps)
5. [Running the Application](#running-the-application)
6. [Troubleshooting](#troubleshooting)
7. [Project Structure](#project-structure)

---

## Prerequisites

Before you begin, ensure you have the following installed on your system:

### Required Software

1. **Flutter SDK (Version 3.9.2 or higher)**
   - Download from: https://flutter.dev/docs/get-started/install
   - Add Flutter to your system PATH
   - Verify installation: `flutter --version`

2. **Dart SDK** (comes with Flutter)
   - Verify: `dart --version`

3. **Git**
   - Download from: https://git-scm.com/downloads
   - Verify: `git --version`

4. **IDE (Choose one)**
   - **Visual Studio Code** (Recommended)
     - Install Flutter extension
     - Install Dart extension
   - **Android Studio**
     - Install Flutter plugin
     - Install Dart plugin

5. **Platform-Specific Requirements**

   **For Android Development:**
   - Android Studio or Android SDK Command-line Tools
   - Java Development Kit (JDK) 11 or higher
   - Android SDK (API level 21 or higher)
   - Android device or emulator

   **For iOS Development (macOS only):**
   - Xcode (latest version)
   - CocoaPods: `sudo gem install cocoapods`
   - iOS Simulator or physical iOS device

   **For Web Development:**
   - Google Chrome browser

   **For Windows Desktop:**
   - Visual Studio 2019 or later with C++ desktop development tools

---

## Project Overview

**MiniMart** is a full-featured e-commerce mobile application built with Flutter that includes:

- User authentication (Sign up, Login, Password Reset)
- Product browsing with categories
- Shopping cart functionality
- Wishlist management
- Order placement and tracking
- Coupon system
- Firebase backend integration
- Responsive UI with dark/light theme support

### Technology Stack

- **Framework:** Flutter 3.9.2+
- **Language:** Dart
- **State Management:** Provider
- **Backend:** Firebase (Authentication, Firestore, Cloud Storage)
- **Image Caching:** cached_network_image, flutter_cache_manager
- **Permissions:** permission_handler

---

## Firebase Configuration

### Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or "Create a project"
3. Enter project name: `minimart-app` (or your preferred name)
4. Enable Google Analytics (optional)
5. Click "Create project"

### Step 2: Enable Firebase Services

1. **Enable Authentication:**
   - In Firebase Console, go to "Authentication"
   - Click "Get started"
   - Enable "Email/Password" sign-in method
   - Click "Save"

2. **Create Firestore Database:**
   - Go to "Firestore Database"
   - Click "Create database"
   - Select "Start in production mode"
   - Choose a location closest to your users
   - Click "Enable"

3. **Update Firestore Security Rules:**
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
       match /products/{productId} {
         allow read: if true;
         allow write: if request.auth != null;
       }
       match /coupons/{couponId} {
         allow read: if request.auth != null;
       }
     }
   }
   ```

### Step 3: Register Your Apps

#### For Android:

1. In Firebase Console, click "Add app" → Android icon
2. Enter Android package name: `com.example.minimart`
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`

#### For iOS:

1. In Firebase Console, click "Add app" → iOS icon
2. Enter iOS bundle ID: `com.example.minimart`
3. Download `GoogleService-Info.plist`
4. Place it in: `ios/Runner/GoogleService-Info.plist`

#### For Web:

1. In Firebase Console, click "Add app" → Web icon
2. Register app nickname: `MiniMart Web`
3. Copy the Firebase configuration
4. The configuration is already integrated in `lib/firebase_options.dart`

### Step 4: Configure FlutterFire CLI (Recommended)

This is the easiest method to configure Firebase for all platforms:

1. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Navigate to your project directory:
   ```bash
   cd path/to/assignment-two-flutter-UI-Group-10-Rabib
   ```

3. Run FlutterFire configuration:
   ```bash
   flutterfire configure
   ```

4. Select your Firebase project from the list
5. Select platforms to configure (Android, iOS, Web, etc.)
6. This will automatically generate `lib/firebase_options.dart`

---

## Installation Steps

### Step 1: Clone or Navigate to Project

```bash
cd c:\Users\AC\Downloads\assignment-two-flutter-UI-Group-10-Rabib\assignment-two-flutter-UI-Group-10-Rabib
```

### Step 2: Install Flutter Dependencies

```bash
flutter pub get
```

This command will install all dependencies listed in `pubspec.yaml`:
- provider
- firebase_core
- firebase_auth
- cloud_firestore
- cached_network_image
- flutter_cache_manager
- permission_handler
- intl
- shared_preferences

### Step 3: Verify Flutter Installation

Check if Flutter is properly configured:

```bash
flutter doctor
```

Address any issues shown (missing SDKs, licenses, etc.)

### Step 4: Accept Android Licenses (Android only)

```bash
flutter doctor --android-licenses
```

Type 'y' to accept all licenses

### Step 5: Update CocoaPods (iOS only, macOS)

```bash
cd ios
pod install
cd ..
```

---

## Running the Application

### Option 1: Run on Android

1. **Start Android Emulator:**
   - Open Android Studio
   - Go to Tools → AVD Manager
   - Start an emulator (or create one if none exists)

2. **Or Connect Physical Device:**
   - Enable Developer Options on your Android device
   - Enable USB Debugging
   - Connect device via USB
   - Verify: `flutter devices`

3. **Run the app:**
   ```bash
   flutter run
   ```

   Or specify device:
   ```bash
   flutter run -d <device-id>
   ```

### Option 2: Run on iOS (macOS only)

1. **Start iOS Simulator:**
   ```bash
   open -a Simulator
   ```

2. **Or Connect Physical Device:**
   - Connect iPhone/iPad via USB
   - Trust the computer on device
   - Verify: `flutter devices`

3. **Run the app:**
   ```bash
   flutter run
   ```

### Option 3: Run on Web

1. **Enable Flutter Web:**
   ```bash
   flutter config --enable-web
   ```

2. **Run on Chrome:**
   ```bash
   flutter run -d chrome
   ```

3. **Or build for deployment:**
   ```bash
   flutter build web
   ```

   Output will be in `build/web/` directory

### Option 4: Run on Windows Desktop

1. **Enable Windows Desktop:**
   ```bash
   flutter config --enable-windows-desktop
   ```

2. **Run on Windows:**
   ```bash
   flutter run -d windows
   ```

---

## Troubleshooting

### Common Issues and Solutions

#### 1. Firebase Configuration Errors

**Error:** `Target of URI doesn't exist: 'package:firebase_core/firebase_core.dart'`

**Solution:**
```bash
flutter pub get
flutter clean
flutter pub get
```

#### 2. Missing google-services.json

**Error:** `File google-services.json is missing`

**Solution:**
- Ensure `google-services.json` is in `android/app/` directory
- Re-download from Firebase Console if needed
- Run `flutter clean` and rebuild

#### 3. Gradle Build Failures (Android)

**Error:** `FAILURE: Build failed with an exception`

**Solution:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

#### 4. CocoaPods Issues (iOS)

**Error:** `Pod install failed`

**Solution:**
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

#### 5. Permission Handler Errors

**Error:** Permission-related crashes on Android

**Solution:**
- Ensure `android/app/src/main/AndroidManifest.xml` has required permissions:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

#### 6. Version Compatibility Issues

**Error:** SDK version mismatch

**Solution:**
- Update Flutter: `flutter upgrade`
- Check `pubspec.yaml` for SDK constraints
- Run: `flutter pub upgrade`

---

## Project Structure

```
minimart/
├── android/                 # Android platform code
├── ios/                     # iOS platform code
├── lib/                     # Dart source code
│   ├── auth/               # Authentication screens
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── models/             # Data models
│   │   ├── product.dart
│   │   └── coupon.dart
│   ├── providers/          # State management
│   │   ├── auth_provider.dart
│   │   ├── cart_provider.dart
│   │   ├── orders_provider.dart
│   │   ├── products_provider.dart
│   │   ├── theme_provider.dart
│   │   └── wishlist_provider.dart
│   ├── screens/            # App screens
│   │   ├── main_screen.dart
│   │   ├── shop_page.dart
│   │   ├── cart_page.dart
│   │   ├── checkout_page.dart
│   │   ├── orders_page.dart
│   │   ├── profile_page.dart
│   │   ├── wishlist_page.dart
│   │   └── product_details_page.dart
│   ├── services/           # Services
│   │   ├── seeder_service.dart
│   │   └── image_cache_service.dart
│   ├── theme/              # App theming
│   │   ├── app_colors.dart
│   │   └── app_theme.dart
│   ├── widgets/            # Reusable widgets
│   │   ├── app_bar.dart
│   │   ├── app_drawer.dart
│   │   ├── cart_item_widget.dart
│   │   ├── custom_bottom_nav_bar.dart
│   │   ├── product_grid_item.dart
│   │   └── splash_screen.dart
│   ├── firebase_options.dart # Firebase config
│   └── main.dart           # App entry point
├── web/                    # Web platform code
├── windows/                # Windows desktop code
├── pubspec.yaml            # Dependencies
└── README.md              # Project documentation
```

---

## Testing the Application

### Create Test Data

1. **Sign Up:**
   - Run the app
   - Click "Sign Up"
   - Enter name, email, phone, password
   - Verify email (check spam folder)

2. **Add Products (via Firebase Console):**
   - Go to Firestore Database
   - Create collection: `products`
   - Add documents with fields:
     - `name` (string)
     - `price` (number)
     - `description` (string)
     - `category` (string)
     - `imageUrl` (string - use public URLs)

3. **Test Coupons:**
   - Coupons are auto-seeded on first run
   - Available codes: `SAVE10`, `WELCOME20`, `FLAT50`

### Features to Test

- ✅ User registration and login
- ✅ Browse products by category
- ✅ Add/remove items from cart
- ✅ Add/remove items from wishlist
- ✅ Apply coupon codes
- ✅ Place orders
- ✅ View order history
- ✅ Update profile information
- ✅ Toggle dark/light theme

---

## Building for Release

### Android APK:

```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (recommended for Play Store):

```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS (macOS only):

```bash
flutter build ios --release
```

### Web:

```bash
flutter build web --release
```
Output: `build/web/`

---

## Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [FlutterFire Documentation](https://firebase.flutter.dev/)

---

## Support

For issues or questions:
1. Check this manual first
2. Review error messages carefully
3. Check Flutter and Firebase documentation
4. Ensure all dependencies are up to date: `flutter pub upgrade`

---

**Last Updated:** December 2025  
**Flutter Version:** 3.9.2+  
**Dart SDK:** ^3.9.2
