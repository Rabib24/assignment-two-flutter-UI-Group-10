import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:minimart/models/product.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String _errorMessage = '';
  List<String> _categories = [];

  List<Product> get products {
    return _products;
  }

  bool get isLoading => _isLoading;
  
  String get errorMessage => _errorMessage;

  List<String> get categories => _categories;

  Future<void> fetchCategories() async {
    try {
      debugPrint("🏷️ Fetching categories from Firestore...");
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();

      final categoriesSet = <String>{'General'}; // Always include General
      for (final doc in snapshot.docs) {
        final category = doc.data()['category'] as String?;
        if (category != null && category.isNotEmpty) {
          categoriesSet.add(category);
        }
      }
      
      _categories = categoriesSet.toList()..sort();
      debugPrint("✅ Successfully loaded ${_categories.length} categories");
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error fetching categories: $e");
      _categories = ['General'];
      notifyListeners();
    }
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      debugPrint("🔍 Fetching products from Firestore...");
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();

      debugPrint("📦 Received ${snapshot.docs.length} products from Firestore");

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
      
      debugPrint("✅ Successfully loaded ${_products.length} products");
      await fetchCategories(); // Fetch categories after products
      _isLoading = false;
      notifyListeners();
    } on FirebaseException catch (e) {
      debugPrint("❌ Firebase error fetching products: ${e.code} - ${e.message}");
      
      if (e.code == 'unavailable') {
        _errorMessage = 'Cannot connect to the server. Please check your internet connection and try again.';
      } else if (e.code == 'permission-denied') {
        _errorMessage = 'Access denied. Please check your permissions.';
      } else {
        _errorMessage = e.message ?? 'Failed to load products';
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error fetching products: $e");
      _errorMessage = 'Failed to load products. Please check your internet connection and try again.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      debugPrint("➕ Adding new product...");
      await FirebaseFirestore.instance.collection('products').add(productData);
      await fetchProducts(); // Refresh list
      debugPrint("✅ Product added successfully");
    } catch (e) {
      debugPrint("❌ Error adding product: $e");
      rethrow;
    }
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> productData) async {
    try {
      debugPrint("✏️ Updating product: $productId");
      await FirebaseFirestore.instance.collection('products').doc(productId).update(productData);
      await fetchProducts(); // Refresh list
      debugPrint("✅ Product updated successfully");
    } catch (e) {
      debugPrint("❌ Error updating product: $e");
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      debugPrint("🗑️ Deleting product: $productId");
      await FirebaseFirestore.instance.collection('products').doc(productId).delete();
      _products.removeWhere((p) => p.id == productId);
      notifyListeners();
      debugPrint("✅ Product deleted successfully");
    } catch (e) {
      debugPrint("❌ Error deleting product: $e");
      rethrow;
    }
  }

  Product? findById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } on StateError {
      // Product not found
      debugPrint('⚠️ Product with id $id not found');
      return null;
    } catch (e) {
      debugPrint('❌ Unexpected error in findById: $e');
      return null;
    }
  }
}