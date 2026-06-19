import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewModel/order_view_model.dart';
import '../../viewModel/product_catalog_view_model.dart';
import '../widgets/catalog_product_card.dart';

class ProductCatalogScreen extends StatelessWidget {
  const ProductCatalogScreen({super.key});

  Future<void> _handleCreateOrder(BuildContext context) async {
    final catalogViewModel = context.read<ProductCatalogViewModel>();
    final orderViewModel = context.read<OrderViewModel>();

    if (catalogViewModel.totalSelectedQuantity == 0) return;

    try {
      await catalogViewModel.createOrders(orderViewModel);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Orders created successfully'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      Navigator.of(context).pop();
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create orders: $error'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Product Catalog'),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: Consumer<ProductCatalogViewModel>(
        builder: (context, catalogViewModel, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  'Select products and quantities to create orders',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 700
                        ? 3
                        : constraints.maxWidth > 480
                            ? 2
                            : 2;

                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: catalogViewModel.products.length,
                      itemBuilder: (context, index) {
                        final product = catalogViewModel.products[index];

                        return CatalogProductCard(
                          product: product,
                          onIncrement: () => catalogViewModel
                              .incrementQuantity(product.name),
                          onDecrement: () => catalogViewModel
                              .decrementQuantity(product.name),
                        );
                      },
                    );
                  },
                ),
              ),
              _CreateOrderBar(
                label: catalogViewModel.createOrderButtonLabel,
                isEnabled: catalogViewModel.totalSelectedQuantity > 0 &&
                    !catalogViewModel.isCreatingOrder,
                isLoading: catalogViewModel.isCreatingOrder,
                onPressed: () => _handleCreateOrder(context),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CreateOrderBar extends StatelessWidget {
  const _CreateOrderBar({
    required this.label,
    required this.isEnabled,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 8,
      color: colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: isEnabled ? onPressed : null,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
