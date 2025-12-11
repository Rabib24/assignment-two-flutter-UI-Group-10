import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minimart/models/product.dart';

class WishlistProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _wishlistIds = [];
  
  List<String> get wishlistIds => [..._wishlistIds];

  WishlistProvider() {
    _fetchWishlist();
  }

  Future<void> _fetchWishlist() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data()!.containsKey('wishlist')) {
        _wishlistIds = List<String>.from(doc.data()!['wishlist']);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching wishlist: $e");
    }
  }

  bool isInWishlist(String productId) {
    return _wishlistIds.contains(productId);
  }

  Future<void> toggleWishlist(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return; // Or prompt login

    try {
      if (_wishlistIds.contains(productId)) {
        _wishlistIds.remove(productId);
      } else {
        _wishlistIds.add(productId);
      }
      notifyListeners();

      await _firestore.collection('users').doc(user.uid).set({
        'wishlist': _wishlistIds,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error updating wishlist: $e");
      // Revert on error
      if (_wishlistIds.contains(productId)) {
         _wishlistIds.remove(productId);
      } else {
        _wishlistIds.add(productId);
      }
      notifyListeners();
    }
  }
}
