// To represent order object
// To convert Firestore data to dart object

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/app_formatter.dart';

class OrderModel {

  final String id;
  final String customerName;
  final String productName;
  final int quantity;
  final double price;
  final String status;
  final Timestamp createdAt;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.status,
    required this.createdAt,
  });


 // Convert Firestore document → OrderModel object.

  factory OrderModel.fromFirestore(
    DocumentSnapshot doc,
  ) {
    // Converts Firestore data into a Dart Map.
    final data = doc.data() as Map<String, dynamic>;

    return OrderModel(
      id: doc.id,
      customerName: data['customerName'],
      productName: data['productName'],
      quantity: data['quantity'],
      price: data['price'].toDouble(),
      status: data['status'],
      createdAt: data['createdAt'],
    );
  }

  String get formattedCreatedDate =>
      AppFormatter.dateFormat.format(createdAt.toDate());

  double get totalAmount {
    return price * quantity;
  }
}