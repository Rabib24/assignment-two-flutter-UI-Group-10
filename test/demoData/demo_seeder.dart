import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DemoDataSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> seedAll() async {
    debugPrint("Starting Demo Data Seeding...");
    await seedProducts();
    await seedCoupons();
    // Users are typically created via Auth, but we can seed a profile
    debugPrint("Demo Data Seeding Completed.");
  }

  static Future<void> seedProducts() async {
    final productsCollection = _firestore.collection('products');
    final snapshot = await productsCollection.limit(1).get();
    
    if (snapshot.docs.isNotEmpty) {
      debugPrint("Products already exist. Skipping seed.");
      return;
    }

    final List<Map<String, dynamic>> products = [
      {
        'name': 'Wireless Headphones',
        'price': 1200.0,
        'category': 'Electronics',
        'description': 'High quality wireless headphones with noise cancellation.',
        'imageUrl': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=1000&auto=format&fit=crop',
      },
      {
        'name': 'Smart Watch',
        'price': 2500.0,
        'category': 'Electronics',
        'description': 'Track your fitness and notifications on the go.',
        'imageUrl': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=1000&auto=format&fit=crop',
      },
      {
        'name': 'Running Shoes',
        'price': 3000.0,
        'category': 'Fashion',
        'description': 'Comfortable running shoes for daily use.',
        'imageUrl': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=1000&auto=format&fit=crop',
      },
      {
        'name': 'Backpack',
        'price': 1500.0,
        'category': 'Fashion',
        'description': 'Durable backpack for school or travel.',
        'imageUrl': 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?q=80&w=1000&auto=format&fit=crop',
      },
      {
        'name': 'Water Bottle',
        'price': 500.0,
        'category': 'Home',
        'description': 'Insulated water bottle to keep drinks cold.',
        'imageUrl': 'https://images.unsplash.com/photo-1602143407151-0111419500be?q=80&w=1000&auto=format&fit=crop',
      },
    ];

    for (var product in products) {
      await productsCollection.add(product);
    }
    debugPrint("Seeded ${products.length} products.");
  }

  static Future<void> seedCoupons() async {
    final couponsCollection = _firestore.collection('coupons');
    final snapshot = await couponsCollection.limit(1).get();

    if (snapshot.docs.isNotEmpty) {
      debugPrint("Coupons already exist. Skipping seed.");
      return;
    }

    final List<Map<String, dynamic>> coupons = [
      {
        'code': 'SAVE10',
        'discountType': 'percentage',
        'discountValue': 10.0,
        'expiryDate': DateTime.now().add(const Duration(days: 365)),
      },
      {
        'code': 'WELCOME20',
        'discountType': 'percentage',
        'discountValue': 20.0,
        'expiryDate': DateTime.now().add(const Duration(days: 365)),
      },
      {
        'code': 'FLAT100',
        'discountType': 'fixed',
        'discountValue': 100.0,
        'expiryDate': DateTime.now().add(const Duration(days: 365)),
      },
    ];

    for (var coupon in coupons) {
      await couponsCollection.add(coupon);
    }
    debugPrint("Seeded ${coupons.length} coupons.");
  }
}
