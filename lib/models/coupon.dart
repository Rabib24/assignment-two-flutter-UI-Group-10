import 'package:cloud_firestore/cloud_firestore.dart';

class Coupon {
  final String id;
  final String code;
  final String discountType; // 'percentage' or 'fixed'
  final double discountValue;
  final DateTime expiryDate;

  Coupon({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.expiryDate,
  });

  factory Coupon.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Coupon(
      id: doc.id,
      code: data['code'] ?? '',
      discountType: data['discountType'] ?? 'fixed',
      discountValue: (data['discountValue'] ?? 0.0).toDouble(),
      expiryDate: (data['expiryDate'] as Timestamp).toDate(),
    );
  }

  bool get isValid {
    return DateTime.now().isBefore(expiryDate);
  }
}
