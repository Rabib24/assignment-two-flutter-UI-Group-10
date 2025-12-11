import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:minimart/models/product.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _products = [];

  List<Product> get products {
    return [..._products];
  }

  Future<void> fetchProducts() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();

      _products = snapshot.docs.map((doc) {
        final data = doc.data();
        return Product(
          id: doc.id,
          name: data['name'] ?? 'Unknown',
          price: (data['price'] is num)
              ? (data['price'] as num).toDouble()
              : 0.0,
          imageUrl: data['imageUrl'] ?? '',
          description: data['description'] ?? '',
          category: data['category'] ?? 'General',
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching products: $e");
    }
  }

  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      await FirebaseFirestore.instance.collection('products').add(productData);
      await fetchProducts(); // Refresh list
    } catch (e) {
      debugPrint("Error adding product: $e");
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await FirebaseFirestore.instance.collection('products').doc(productId).delete();
      _products.removeWhere((p) => p.id == productId);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting product: $e");
      rethrow;
    }
  }

  Product? findById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }
}
