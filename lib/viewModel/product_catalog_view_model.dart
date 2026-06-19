import 'package:flutter/material.dart';

import '../data/models/catalog_product.dart';
import 'order_view_model.dart';

class ProductCatalogViewModel extends ChangeNotifier {

  static const String walkInCustomer = 'Walk-in Customer';
  static const String defaultStatus = 'Pending';

  final List<CatalogProduct> _products = [
    CatalogProduct(
      name: 'Laptop',
      price: 55000,
      imagePath: 'assets/images/laptop.png',
    ),
    CatalogProduct(
      name: 'Mobile',
      price: 25000,
      imagePath: 'assets/images/mobile.png',
    ),
    CatalogProduct(
      name: 'Keyboard',
      price: 2500,
      imagePath: 'assets/images/keyboard.png',
    ),
    CatalogProduct(
      name: 'Mouse',
      price: 800,
      imagePath: 'assets/images/mouse.png',
    ),
    CatalogProduct(
      name: 'Headset',
      price: 3500,
      imagePath: 'assets/images/headset.png',
    ),
    CatalogProduct(
      name: 'Monitor',
      price: 15000,
      imagePath: 'assets/images/monitor.png',
    ),
  ];

  bool _isCreatingOrder = false;

  // To prevent external modification.
  List<CatalogProduct> get products => List.unmodifiable(_products);

  bool get isCreatingOrder => _isCreatingOrder;

  int get totalSelectedQuantity {
    return _products.fold(0, (sum, product) => sum + product.quantity);
  }

  List<CatalogProduct> get selectedProducts {
    return _products.where((product) => product.quantity > 0).toList();
  }

  String get createOrderButtonLabel {
    final count = totalSelectedQuantity;
    if (count == 1) {
      return 'Create Order (1 Item)';
    }
    return 'Create Order ($count Items)';
  }

  void incrementQuantity(String productName) {
    final product = _findProduct(productName);
    if (product == null) return;

    product.quantity++;
    notifyListeners();
  }

  void decrementQuantity(String productName) {
    final product = _findProduct(productName);
    if (product == null || product.quantity <= 0) return;

    product.quantity--;
    notifyListeners();
  }

  Future<void> createOrders(OrderViewModel orderViewModel) async {
    if (_isCreatingOrder || totalSelectedQuantity == 0) return;

    _isCreatingOrder = true;
    notifyListeners();

    try {
      for (final product in selectedProducts) {
        await orderViewModel.addOrder(
          customerName: walkInCustomer,
          productName: product.name,
          quantity: product.quantity,
          price: product.price,
          status: defaultStatus,
        );
      }

      resetQuantities();
    } finally {
      _isCreatingOrder = false;
      notifyListeners();
    }
  }

  void resetQuantities() {
    for (final product in _products) {
      product.quantity = 0;
    }
    notifyListeners();
  }

  CatalogProduct? _findProduct(String productName) {
    for (final product in _products) {
      if (product.name == productName) {
        return product;
      }
    }
    return null;
  }
}
