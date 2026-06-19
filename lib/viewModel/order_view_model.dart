import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../data/models/order_model.dart';
import '../data/models/order_statistics.dart';
import '../services/firestore_service.dart';

class OrderViewModel extends ChangeNotifier {

  final FirestoreService _service = FirestoreService();

  static const List<String> statusOptions = [
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled',
  ];

  String _searchQuery = '';

  String get searchQuery => _searchQuery;

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  Stream<QuerySnapshot> get orders => _service.getOrders();
 // Convert Firestore document to Dart object
  List<OrderModel> parseOrders(QuerySnapshot snapshot) {
    return snapshot.docs.map(OrderModel.fromFirestore).toList();
  }

  List<OrderModel> filterByCustomerName(
      List<OrderModel> orders,
      String query,
      ) {
    if (query.trim().isEmpty) return orders;

    final normalizedQuery = query.trim().toLowerCase();

    return orders.where((order) {
      return order.customerName
          .toLowerCase()
          .contains(normalizedQuery);
    }).toList();
  }

  OrderStatistics calculateStatistics(
      List<OrderModel> orders,
      ) {
    if (orders.isEmpty) {
      return OrderStatistics.empty;
    }

    int pending = 0;
    int processing = 0;
    int delivered = 0;
    int cancelled = 0;

    for (final order in orders) {
      switch (order.status.toLowerCase()) {
        case 'pending':
          pending++;
          break;

        case 'processing':
          processing++;
          break;

        case 'delivered':
        case 'completed':
          delivered++;
          break;

        case 'cancelled':
          cancelled++;
          break;
      }
    }

    return OrderStatistics(
      total: orders.length,
      pending: pending,
      processing: processing,
      delivered: delivered,
      cancelled: cancelled,
    );
  }

  Color statusColor(
      String status,
      ColorScheme colorScheme,
      ) {
    switch (status.toLowerCase()) {
      case 'pending':
        return colorScheme.tertiary;

      case 'processing':
        return colorScheme.primary;

      case 'shipped':
        return const Color(0xFF7B1FA2);

      case 'delivered':
      case 'completed':
        return const Color(0xFF2E7D32);

      case 'cancelled':
        return colorScheme.error;

      default:
        return colorScheme.outline;
    }
  }

  Future<void> addOrder({
    required String customerName,
    required String productName,
    required int quantity,
    required double price,
    required String status,
  }) async {
    final payload = {
      'customerName': customerName,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'status': status,
      'createdAt': Timestamp.now(),
    };

    try {
      await _service.addOrder(payload);

      debugPrint(
        '[OrderViewModel] Order added successfully',
      );
    } catch (e) {
      debugPrint(
        '[OrderViewModel] Failed to add order: $e',
      );
      rethrow;
    }
  }

  Future<void> updateOrder({
    required String id,
    required String customerName,
    required String productName,
    required int quantity,
    required double price,
    required String status,
  }) async {
    final payload = {
      'customerName': customerName,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'status': status,
    };

    try {
      await _service.updateOrder(id, payload);

      debugPrint(
        '[OrderViewModel] Order updated successfully',
      );
    } catch (e) {
      debugPrint(
        '[OrderViewModel] Failed to update order: $e',
      );
      rethrow;
    }
  }

  Future<void> deleteOrder(String id) async {
    try {
      await _service.deleteOrder(id);

      debugPrint(
        '[OrderViewModel] Order deleted successfully',
      );
    } catch (e) {
      debugPrint(
        '[OrderViewModel] Failed to delete order: $e',
      );
      rethrow;
    }
  }

  Future<void> saveOrder({
    OrderModel? order,
    required String customerName,
    required String productName,
    required int quantity,
    required double price,
    required String status,
  }) async {
    if (order == null) {
      await addOrder(
        customerName: customerName,
        productName: productName,
        quantity: quantity,
        price: price,
        status: status,
      );
      return;
    }

    await updateOrder(
      id: order.id,
      customerName: customerName,
      productName: productName,
      quantity: quantity,
      price: price,
      status: status,
    );
  }
}