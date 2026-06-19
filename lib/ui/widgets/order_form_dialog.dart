import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../data/models/order_model.dart';

typedef OrderSaveCallback = Future<void> Function({
  required String customerName,
  required String productName,
  required int quantity,
  required double price,
  required String status,
});

class OrderFormDialog extends StatefulWidget {
  const OrderFormDialog({
    super.key,
    required this.statusOptions,
    required this.onSave,
    this.order,
  });

  final OrderModel? order;
  final List<String> statusOptions;
  final OrderSaveCallback onSave;

  @override
  State<OrderFormDialog> createState() => _OrderFormDialogState();
}

class _OrderFormDialogState extends State<OrderFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _customerController;
  late final TextEditingController _productController;
  late final TextEditingController _quantityController;
  late final TextEditingController _priceController;
  late String _selectedStatus;
  bool _isSaving = false;

  bool get _isEditing => widget.order != null;

  @override
  void initState() {
    super.initState();
    final order = widget.order;
    _customerController = TextEditingController(text: order?.customerName ?? '');
    _productController = TextEditingController(text: order?.productName ?? '');
    _quantityController = TextEditingController(
      text: order?.quantity.toString() ?? '',
    );
    _priceController = TextEditingController(
      text: order?.price.toString() ?? '',
    );
    _selectedStatus = order?.status ?? widget.statusOptions.first;
  }

  @override
  void dispose() {
    _customerController.dispose();
    _productController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(
    ColorScheme colorScheme, {
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.25),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.error),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await widget.onSave(
        customerName: _customerController.text.trim(),
        productName: _productController.text.trim(),
        quantity: int.parse(_quantityController.text.trim()),
        price: double.parse(_priceController.text.trim()),
        status: _selectedStatus,
      );

      if (mounted) Navigator.of(context).pop();
    } catch (e, stackTrace) {
      debugPrint('[OrderFormDialog] submit — FAILED');
      debugPrint('[OrderFormDialog]   exception: $e');
      debugPrint('[OrderFormDialog]   stackTrace: $stackTrace');

      if (mounted) {
        final message = e is FirebaseException
            ? '${e.code}: ${e.message}'
            : e.toString();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Failed to update order. $message'
                  : 'Failed to add order. $message',
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth > 600 ? 480.0 : 360.0;

        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          title: Text(_isEditing ? 'Edit Order' : 'Add Order'),
          content: SizedBox(
            width: maxWidth,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _customerController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _fieldDecoration(
                        colorScheme,
                        label: 'Customer Name',
                        icon: Icons.person_outline,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Customer name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _productController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _fieldDecoration(
                        colorScheme,
                        label: 'Product Name',
                        icon: Icons.inventory_2_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Product name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: _fieldDecoration(
                        colorScheme,
                        label: 'Quantity',
                        icon: Icons.numbers_rounded,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Quantity is required';
                        }
                        final quantity = int.tryParse(value.trim());
                        if (quantity == null || quantity <= 0) {
                          return 'Enter a valid quantity';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _fieldDecoration(
                        colorScheme,
                        label: 'Unit Price',
                        icon: Icons.currency_rupee_rounded,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Price is required';
                        }
                        final price = double.tryParse(value.trim());
                        if (price == null || price <= 0) {
                          return 'Enter a valid price';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedStatus,
                      decoration: _fieldDecoration(
                        colorScheme,
                        label: 'Status',
                        icon: Icons.flag_outlined,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      items: widget.statusOptions
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ),
                          )
                          .toList(),
                      onChanged: _isSaving
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() => _selectedStatus = value);
                              }
                            },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: _isSaving ? null : _submit,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }
}
