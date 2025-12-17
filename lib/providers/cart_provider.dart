import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minimart/models/coupon.dart';

class CartItem {
  final String id;
  final String name;
  final int quantity;
  final double price;

  CartItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
  });
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  CartProvider() {
    _initializeCart();
  }

  Future<void> _initializeCart() async {
    // TODO: Implement persistent cart loading from SharedPreferences
    // For now, cart starts empty and will be saved on modifications
    debugPrint('[CartProvider] Cart initialized');
  }

  Map<String, CartItem> get items {
    return _items;
  }

  int get itemCount {
    return _items.length;
  }

  Coupon? _coupon;

  Coupon? get coupon => _coupon;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    
    if (_coupon != null) {
      if (_coupon!.discountType == 'percentage') {
        total = total * (1 - (_coupon!.discountValue / 100));
      } else {
        total = total - _coupon!.discountValue;
      }
    }
    
    return total < 0 ? 0 : total;
  }

  double get subtotal {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  double get discountAmount {
    if (_coupon == null) return 0.0;
    return subtotal - totalAmount;
  }

  Future<void> applyCoupon(String code) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('coupons')
          .where('code', isEqualTo: code)
          .get();

      if (snapshot.docs.isEmpty) {
        throw "Invalid coupon code";
      }

      final coupon = Coupon.fromFirestore(snapshot.docs.first);
      if (!coupon.isValid) {
        throw "Coupon has expired";
      }

      _coupon = coupon;
      notifyListeners();
    } catch (e) {
      throw e.toString();
    }
  }

  void removeCoupon() {
    _coupon = null;
    notifyListeners();
  }

  void addItem(String productId, double price, String title) {
    if (_items.containsKey(productId)) {
      // Efficiently update quantity without creating new object
      final existingItem = _items[productId]!;
      _items[productId] = CartItem(
        id: existingItem.id,
        name: existingItem.name,
        quantity: existingItem.quantity + 1,
        price: existingItem.price,
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: productId,
          name: title,
          quantity: 1,
          price: price,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          name: existingCartItem.name,
          quantity: existingCartItem.quantity - 1,
          price: existingCartItem.price,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _coupon = null;
    notifyListeners();
  }
}
