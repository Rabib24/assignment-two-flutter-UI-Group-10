# MiniMart Project Setup Guide

This guide will help you set up and run the MiniMart Flutter project on any machine, including faculty computers.

## Prerequisites

1. **Flutter SDK** (version 3.9.2 or higher)
2. **Android Studio** or **Visual Studio Code** with Flutter extensions
3. **Git** for version control
4. **Internet connection** for downloading dependencies

## Installation Steps

### 1. Clone the Repository
```bash
git clone https://github.com/Rabib24/assignment-two-flutter-UI-Group-10.git
cd assignment-two-flutter-UI-Group-10
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Verify Setup
```bash
flutter doctor
```
Ensure all checks pass before proceeding.

## Firebase Configuration (Required)

The project uses Firebase for authentication and data storage. You need to set up your own Firebase project:

### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name (e.g., "MiniMart")
4. Accept default settings and create project

### Step 2: Register Apps
#### For Android:
1. In Firebase Console, click "Add app" → "Android"
2. Package name: `com.example.minimart`
3. App nickname: "MiniMart Android"
4. Download `google-services.json`
5. Place it in: `android/app/`

#### For iOS:
1. In Firebase Console, click "Add app" → "iOS"
2. Bundle ID: `com.example.minimart`
3. App nickname: "MiniMart iOS"
4. Download `GoogleService-Info.plist`
5. Place it in: `ios/Runner/`

### Step 3: Configure FlutterFire
Run the configuration tool:
```bash
flutterfire configure
```
Select your Firebase project and platforms (Android, iOS).

### Step 4: Enable Firebase Services
In Firebase Console, enable:
1. **Authentication** → Sign-in method → Email/Password
2. **Firestore Database** → Create database → Start in test mode
3. Add the following collections:
   - `users` (empty to start)
   - `products` (seed with sample data)
   - `orders` (empty to start)
   - `coupons` (seed with sample data)

## Running the Application

### On Android Emulator/Simulator:
```bash
flutter run
```

### On Physical Device:
Connect device via USB and enable developer options:
```bash
flutter run
```

### On Web Browser:
```bash
flutter run -d chrome
```

## Seeding Initial Data (Optional)

To populate the database with sample products and coupons:

1. Run the app once
2. Navigate to Admin Panel (hidden button in Profile if user role is 'admin')
3. Use the seeder service to add sample data

OR manually add to Firestore:
- **Products collection**: Add sample products with name, price, description, imageUrl, category
- **Coupons collection**: Add sample coupons with code, discountType, value, expiryDate, isActive

## Common Issues and Solutions

### 1. "Firebase config file not found"
**Solution**: Complete Firebase setup as described above.

### 2. "No devices found"
**Solution**: 
- Ensure Android emulator is running or device is connected
- For web, ensure Chrome is installed

### 3. "Podfile not found" (iOS)
**Solution**:
```bash
cd ios
pod install
cd ..
```

### 4. "Gradle build failed" (Android)
**Solution**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

## Project Structure Overview

- `lib/` - Main source code
- `lib/screens/` - UI screens
- `lib/providers/` - State management
- `lib/models/` - Data models
- `lib/services/` - Utility services
- `assets/` - Images and static files
- `test/` - Unit and widget tests

## Testing the Application

Run all tests:
```bash
flutter test
```

Run specific test file:
```bash
flutter test test/widget_test.dart
```

## Building Release Versions

### Android APK:
```bash
flutter build apk
```

### iOS:
```bash
flutter build ios
```

### Web:
```bash
flutter build web
```

## Additional Notes

1. **Performance**: The app has been optimized to reduce frame drops and improve responsiveness
2. **Responsive Design**: Works on various screen sizes
3. **Offline Support**: Basic offline functionality with local caching
4. **Security**: Implements proper Firebase security rules

For any issues, contact the development team or check the documentation in the `resourse/` folder.