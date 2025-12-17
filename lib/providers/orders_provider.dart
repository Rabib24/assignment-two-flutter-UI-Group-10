import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:minimart/providers/cart_provider.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;
  final String status;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String? paymentMethod;
  final String? couponCode;
  final String? couponType;
  final double? couponValue;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
    this.status = 'Order Placed',
    this.customerName = '',
    this.customerPhone = '',
    this.customerAddress = '',
    this.paymentMethod,
    this.couponCode,
    this.couponType,
    this.couponValue,
  });
}

class OrdersProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return _orders;
  }

  Future<void> fetchOrders() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .orderBy('dateTime', descending: true)
          .get();

      _orders = snapshot.docs.map((doc) {
        final data = doc.data();
        return OrderItem(
          id: doc.id,
          amount: (data['amount'] ?? 0.0) is num ? (data['amount'] as num).toDouble() : 0.0,
          dateTime: data['dateTime'] != null 
              ? (data['dateTime'] as Timestamp).toDate() 
              : DateTime.now(),
          status: data['status'] ?? 'Order Placed',
          customerName: data['customerName'] ?? '',
          customerPhone: data['customerPhone'] ?? '',
          customerAddress: data['customerAddress'] ?? '',
          paymentMethod: data['paymentMethod'],
          couponCode: data['couponCode'],
          couponType: data['couponType'],
          couponValue: data['couponValue'] is num ? (data['couponValue'] as num).toDouble() : null,
          products: (data['products'] as List<dynamic>? ?? [])
              .map(
                (item) => CartItem(
                  id: item['id'] ?? '',
                  name: item['title'] ?? 'Unknown',
                  quantity: item['quantity'] ?? 1,
                  price: (item['price'] ?? 0.0) is num ? (item['price'] as num).toDouble() : 0.0,
                ),
              )
              .toList(),
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching orders: $e");
    }
  }

  Future<void> addOrder(
    List<CartItem> cartProducts,
    double total,
    String name,
    String phone,
    String address,
    String? paymentMethod,
    String? couponCode,
    String? couponType,
    double? couponValue,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final timestamp = DateTime.now();

    try {
      final docRef = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .add({
            'amount': total,
            'dateTime': timestamp,
            'status': 'Order Placed',
            'customerName': name,
            'customerPhone': phone,
            'customerAddress': address,
            'paymentMethod': paymentMethod,
            'couponCode': couponCode,
            'couponType': couponType,
            'couponValue': couponValue,
            'products': cartProducts
                .map(
                  (cp) => {
                    'id': cp.id,
                    'title': cp.name,
                    'quantity': cp.quantity,
                    'price': cp.price,
                  },
                )
                .toList(),
          });

      _orders.insert(
        0,
        OrderItem(
          id: docRef.id,
          amount: total,
          products: cartProducts,
          dateTime: timestamp,
          status: 'Order Placed',
          customerName: name,
          customerPhone: phone,
          customerAddress: address,
          paymentMethod: paymentMethod,
          couponCode: couponCode,
          couponType: couponType,
          couponValue: couponValue,
        ),
      );
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding order: $e");
      rethrow;
    }
  }
}
