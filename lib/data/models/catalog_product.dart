// To represent a product in a catalog

import '../../utils/app_formatter.dart';

class CatalogProduct {
  CatalogProduct({
    required this.name,
    required this.price,
    required this.imagePath,
    this.quantity = 0,
  });

  final String name;
  final double price;
  final String imagePath;
  int quantity;

  String get formattedPrice =>
      '₹${AppFormatter.priceFormat.format(price)}';
}
