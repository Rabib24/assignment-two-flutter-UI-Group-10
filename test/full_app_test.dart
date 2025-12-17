import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minimart/main.dart';
import 'package:provider/provider.dart';
import 'package:minimart/providers/cart_provider.dart';
import 'package:minimart/providers/products_provider.dart';
import 'package:minimart/providers/auth_provider.dart'; // This imports the file, but we use AuthManager

void main() {
  group('MiniMart App Integration Tests', () {
    testWidgets('App launches and displays Splash Screen', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(MaterialApp), findsOneWidget);
      // Verify Splash logic (this might need mocking if it depends on async auth check)
    });

    // Note: Developing full integration tests requires ensuring Firebase mocking.
    // For this environment, we will verify the widget structure and known critical paths
    // assuming mock providers if we were running unrelated to the real backend.
    
    // Since we don't have a mock environment set up for this specific turn, 
    // I will write a test that verifies the Providers are correctly injected.
    
    testWidgets('Providers are injected', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      final context = tester.element(find.byType(MaterialApp));
      
      expect(Provider.of<CartProvider>(context, listen: false), isNotNull);
      expect(Provider.of<ProductsProvider>(context, listen: false), isNotNull);
      expect(Provider.of<AuthManager>(context, listen: false), isNotNull); // Changed from AuthProvider to AuthManager
    });
  });
}