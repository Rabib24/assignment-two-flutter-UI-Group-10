import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class SeederService {
  static Future<void> seedCoupons() async {
    try {
      final collection = FirebaseFirestore.instance.collection('coupons');
      final snapshot = await collection.limit(1).get();

      if (snapshot.docs.isEmpty) {
        debugPrint("Seeding coupons...");
        await collection.add({
          'code': 'SAVE10',
          'discountType': 'percentage',
          'discountValue': 10.0,
          'expiryDate': DateTime.now().add(const Duration(days: 365)),
        });
        await collection.add({
          'code': 'WELCOME20',
          'discountType': 'percentage',
          'discountValue': 20.0,
          'expiryDate': DateTime.now().add(const Duration(days: 365)),
        });
         await collection.add({
          'code': 'FLAT50',
          'discountType': 'fixed',
          'discountValue': 50.0,
          'expiryDate': DateTime.now().add(const Duration(days: 365)),
        });
        debugPrint("Coupons seeded successfully.");
      }
    } catch (e) {
      debugPrint("Error seeding coupons: $e");
    }
  }
}
