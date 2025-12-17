# MiniMart - E-commerce Flutter Application

A full-featured e-commerce mobile application built with Flutter and Firebase.

## Quick Setup for Faculty

To run this project quickly:

1. Ensure Flutter is installed on your system
2. Run the setup script: `setup_project.bat` (Windows) or follow manual steps below
3. Create a Firebase project and configure `lib/firebase_options.dart`
4. Run with `flutter run`

## Manual Setup Instructions

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Configure Firebase**:
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project
   - Register your app (Android, iOS, Web as needed)
   - Download configuration files
   - Rename `lib/firebase_options_template.dart` to `lib/firebase_options.dart`
   - Replace placeholder values with your actual Firebase configuration

3. **Run the application**:
   ```bash
   flutter run
   ```

## Project Overview

This is a group project (Group 10) for a mobile application development course. The application implements a complete e-commerce solution with features including:

- User authentication (sign up, login, email verification)
- Product catalog with search and filtering
- Shopping cart functionality
- Order placement and history
- Admin panel for product management
- Wishlist functionality
- Dark mode support
- Coupon system

## Key Features

- Real-time data synchronization with Firebase Firestore
- Responsive UI design for various screen sizes
- Performance optimized with proper state management
- Secure authentication with Firebase Authentication
- Offline support with local data caching

## Technologies Used

- Flutter (Dart)
- Firebase (Authentication, Firestore)
- Provider for state management

## Getting Started

See the setup instructions above for detailed installation and configuration.