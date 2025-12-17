import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minimart/providers/cart_provider.dart';
import 'package:minimart/providers/auth_provider.dart'; // Still importing the file
import 'package:minimart/providers/orders_provider.dart';
import 'package:minimart/providers/products_provider.dart';
import 'package:minimart/providers/theme_provider.dart';
import 'package:minimart/providers/wishlist_provider.dart';
import 'package:minimart/widgets/splash_screen.dart';
import 'package:minimart/auth/login_screen.dart';
import 'package:minimart/auth/signup_screen.dart';
import 'package:minimart/auth/forgot_password_screen.dart';
import 'package:minimart/screens/cart_page.dart';
import 'package:minimart/screens/wishlist_page.dart';
import 'package:minimart/screens/orders_page.dart';
import 'package:minimart/screens/profile_page.dart';
import 'package:minimart/screens/settings_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:minimart/firebase_options.dart';
import 'package:minimart/theme/app_theme.dart';
import 'package:minimart/services/seeder_service.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

// Import for Firebase Auth settings
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase only if it hasn't been initialized already
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    
    // Configure Firebase Auth settings for web
    if (kIsWeb) {
      // For web, we need to configure reCAPTCHA
      await FirebaseAuth.instance.setSettings(
        appVerificationDisabledForTesting: false,
      );
    }
    
    // Seed coupons and products on first run
    await SeederService.seedCoupons();
    await SeederService.seedProducts();
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') {
      rethrow;
    }
  }

  // No storage permissions needed - using only Unsplash URLs (no file uploads)
  // This complies with project restrictions

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AuthManager()), // Updated to use AuthManager
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'MiniMart',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/signup': (context) => const SignupScreen(),
              '/forgot-password': (context) => const ForgotPasswordScreen(),
              '/cart': (context) => const CartPage(),
              '/wishlist': (context) => const WishlistPage(),
              '/orders': (context) => const OrdersPage(),
              '/profile': (context) => const ProfilePage(),
              // Add settings route
              '/settings': (context) => const SettingsPage(),
            },
            // Handle unknown routes
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const Scaffold(
                  body: Center(
                    child: Text('Page not found'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}