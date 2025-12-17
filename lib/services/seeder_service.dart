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

  static Future<void> seedProducts() async {
    try {
      final collection = FirebaseFirestore.instance.collection('products');
      final snapshot = await collection.limit(1).get();

      if (snapshot.docs.isEmpty) {
        debugPrint("🌱 Seeding products...");
        
        final List<Map<String, dynamic>> products = [
          // Electronics Category (10 products)
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
            'name': 'Bluetooth Speaker',
            'price': 1500.0,
            'category': 'Electronics',
            'description': 'Portable speaker with excellent sound quality.',
            'imageUrl': 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?q=80&w=1000&auto=format&fit=crop',
          },
          {
            'name': 'USB-C Cable',
            'price': 300.0,
            'category': 'Electronics',
            'description': 'Fast charging USB-C cable, 2 meters long.',
            'imageUrl': 'https://images.unsplash.com/photo-1583863788434-e58a36330cf0?q=80&w=1000&auto=format&fit=crop',
          },
          {
            'name': 'Power Bank',
            'price': 1800.0,
            'category': 'Electronics',
            'description': '20000mAh power bank with fast charging.',
            'imageUrl': 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?q=80&w=1000&auto=format&fit=crop',
          },
          {
            'name': 'Laptop Stand',
            'price': 800.0,
            'category': 'Electronics',
            'description': 'Adjustable aluminum laptop stand for better ergonomics.',
            'imageUrl': 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?q=80&w=1000&auto=format&fit=crop',
          },
          {
            'name': 'Wireless Mouse',
            'price': 600.0,
            'category': 'Electronics',
            'description': 'Ergonomic wireless mouse with precision tracking.',
            'imageUrl': 'https://images.unsplash.com/photo-1527814050087-3793815479db?q=80&w=1000&auto=format&fit=crop',
          },
          {
            'name': 'Keyboard',
            'price': 1200.0,
            'category': 'Electronics',
            'description': 'Mechanical keyboard with RGB backlight.',
            'imageUrl': 'https://images.unsplash.com/photo-1587829741301-dc798b83add3?q=80&w=1000&auto=format&fit=crop',
          },
          {
            'name': 'Phone Case',
            'price': 400.0,
            'category': 'Electronics',
            'description': 'Protective phone case with shock absorption.',
            'imageUrl': 'https://images.unsplash.com/photo-1601784551446-20c9e07cdbdb?q=80&w=1000&auto=format&fit=crop',
          },
          {
            'name': 'Screen Protector',
            'price': 250.0,
            'category': 'Electronics',
            'description': 'Tempered glass screen protector for smartphones.',
            'imageUrl': 'https://images.unsplash.com/photo-1556656793-08538906a9f8?q=80&w=1000&auto=format&fit=crop',
          },
          
          // Fashion Category (10 products)
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
            'name': 'Sunglasses',
            'price': 800.0,
            'category': 'Fashion',
            'description': 'UV protection sunglasses with modern design.',
            'imageUrl': 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?q=80&w=1000&auto=format&fit=crop',
          },
          {
            'name': 'Watch',
            'price': 2000.0,
            'category': 'Fashion',
            'description': 'Elegant analog watch with leather strap.',
            'imageUrl': 'https://images.unsplash.com/photo-1524805444758-089113d48a6d?q=80&w=1000&auto=format&fit=crop',
          },
          {
            'name': 'Baseball Cap',
            'price': 500.0,
            'category': 'Fashion',
            'description': 'Adjustable baseball cap for casual wear.',
            'imageUrl': 'https://images.unsplash.com/photo-1588850561407-ed78c282e89b?q=80&w=1000&auto=format&fit=crop',
          },
          {
            'name': 'Wallet',
            'price': 700.0,
            'category': 'Fashion',
            'description': 'Leather wallet with multiple card slots.',
            'imageUrl': 'https://images.unsplash.com/photo-1627123424574-724758594e93?q=80&w=1000&auto=format&fit=crop',
          },
          {
            'name': 'Belt',
            'price': 600.0,
            'category': 'Fashion',
            'description': 'Classic leather belt for formal and casual wear.',
            'imageUrl': 'https://images.unsplash.com/photo-1624222247344-550fb60583b1?q=80&w=1000&auto=format&fit=crop',
          },
          {
            'name': 'Scarf',
            'price': 450.0,
            'category': 'Fashion',
            'description': 'Soft woolen scarf for winter season.',
            'imageUrl': 'https://images.unsplash.com/photo-1520903920243-00d872a2d1c9?q=80&w=1000&auto=format&fit=crop',
          },
          {
            'name': 'Gloves',
            'price': 400.0,
            'category': 'Fashion',
            'description': 'Warm winter gloves with touchscreen compatibility.',
            'imageUrl': 'https://images.unsplash.com/photo-1601924994987-69e26d50dc26?q=80&w=1000&auto=format&fit=crop',
          },
          {
            'name': 'Sneakers',
            'price': 2500.0,
            'category': 'Fashion',
            'description': 'Trendy sneakers for everyday wear.',
            'imageUrl': 'https://images.unsplash.com/photo-1460353581641-37baddab0fa2?q=80&w=1000&auto=format&fit=crop',
          },
          
          // Home Category (10 products)
          {
            'name': 'Water Bottle',
            'price': 500.0,
            'category': 'Home',
            'description': 'Insulated water bottle to keep drinks cold.',
            'imageUrl': 'https://images.unsplash.com/photo-1602143407151-0111419500be?q=80&w=1000&auto=format&fit=crop',
          },
          {
            'name': 'Coffee Mug',
            'price': 350.0,
            'category': 'Home',
            'description': 'Ceramic coffee mug with unique design.',
            'imageUrl': 'https://images.unsplash.com/photo-1514228742587-6b1558fcca3d?q=80&w=1000&auto=format&fit=crop',
          },
          {
            'name': 'Desk Lamp',
            'price': 900.0,
            'category': 'Home',
            'description': 'LED desk lamp with adjustable brightness.',
            'imageUrl': 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?q=80&w=1000&auto=format&fit=crop',
          },
          {
            'name': 'Plant Pot',
            'price': 400.0,
            'category': 'Home',
            'description': 'Decorative ceramic plant pot for indoor plants.',
            'imageUrl': 'https://images.unsplash.com/photo-1485955900006-10f4d324d411?q=80&w=1000&auto=format&fit=crop',
          },
          {
            'name': 'Wall Clock',
            'price': 800.0,
            'category': 'Home',
            'description': 'Modern wall clock with silent movement.',
            'imageUrl': 'https://images.unsplash.com/photo-1563861826100-9cb868fdbe1c?q=80&w=1000&auto=format&fit=crop',
          },
          {
            'name': 'Cushion',
            'price': 600.0,
            'category': 'Home',
            'description': 'Soft decorative cushion with colorful design.',
            'imageUrl': 'https://images.unsplash.com/photo-1584100936595-c0654b55a2e2?q=80&w=1000&auto=format&fit=crop',
          },
          {
            'name': 'Candle Set',
            'price': 700.0,
            'category': 'Home',
            'description': 'Scented candle set for relaxation.',
            'imageUrl': 'https://images.unsplash.com/photo-1602874801006-ec99927dcfb0?q=80&w=1000&auto=format&fit=crop',
          },
          {
            'name': 'Photo Frame',
            'price': 450.0,
            'category': 'Home',
            'description': 'Wooden photo frame for cherished memories.',
            'imageUrl': 'https://images.unsplash.com/photo-1513519245088-0e12902e35ca?q=80&w=1000&auto=format&fit=crop',
          },
          {
            'name': 'Throw Blanket',
            'price': 1200.0,
            'category': 'Home',
            'description': 'Cozy throw blanket for living room.',
            'imageUrl': 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?q=80&w=1000&auto=format&fit=crop',
          },
          {
            'name': 'Storage Basket',
            'price': 550.0,
            'category': 'Home',
            'description': 'Woven storage basket for organizing items.',
            'imageUrl': 'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?q=80&w=1000&auto=format&fit=crop',
          },
        ];

        for (var product in products) {
          await collection.add(product);
        }
        
        debugPrint("✅ Seeded ${products.length} products successfully.");
      } else {
        debugPrint("ℹ️ Products already exist. Skipping seed.");
      }
    } on FirebaseException catch (e) {
      debugPrint("❌ Firebase error seeding products: ${e.code} - ${e.message}");
      if (e.code == 'unavailable') {
        debugPrint("⚠️ Network connectivity issue. Please check your internet connection.");
      }
    } catch (e) {
      debugPrint("❌ Error seeding products: $e");
      debugPrint("⚠️ This might be a network connectivity issue. Please ensure you have a stable internet connection.");
    }
  }
}
