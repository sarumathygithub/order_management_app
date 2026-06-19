import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/order_model.dart';
import '../../viewModel/auth_view_model.dart';
import '../../viewModel/order_view_model.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_stats.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/loading_state.dart';
import '../widgets/order_card.dart';
import '../widgets/order_form_dialog.dart';
import '../widgets/search_section.dart';
import 'product_catalog_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _searchController = TextEditingController();
  int _retryKey = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openProfileScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );
  }

  Future<void> _showOrderDialog({OrderModel? order}) async {
    final orderViewModel = context.read<OrderViewModel>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => OrderFormDialog(
        order: order,
        statusOptions: OrderViewModel.statusOptions,
        onSave:
            ({
              required String customerName,
              required String productName,
              required int quantity,
              required double price,
              required String status,
            }) {
              return orderViewModel.saveOrder(
                order: order,
                customerName: customerName,
                productName: productName,
                quantity: quantity,
                price: price,
                status: status,
              );
            },
      ),
    );
  }

  Future<void> _confirmDelete(OrderModel order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Order'),
        content: Text(
          'Are you sure you want to delete the order for '
          '"${order.customerName}"?',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<OrderViewModel>().deleteOrder(order.id);
    }
  }

  void _retryLoading() {
    setState(() => _retryKey++);
  }

  void _openProductCatalog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProductCatalogScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final orderViewModel = context.read<OrderViewModel>();
    final authViewModel = context.read<AuthViewModel>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showOrderDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Order'),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          key: ValueKey(_retryKey),
          stream: orderViewModel.orders,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingState();
            }

            if (snapshot.hasError) {
              return ErrorState(
                message: 'Failed to load orders. Please try again.',
                onRetry: _retryLoading,
              );
            }

            return Consumer<OrderViewModel>(
              builder: (context, vm, child) {
                final orders = orderViewModel.parseOrders(snapshot.data!);
                final filteredOrders = orderViewModel.filterByCustomerName(
                  orders,
                  orderViewModel.searchQuery,
                );

                final statistics = orderViewModel.calculateStatistics(orders);

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: DashboardHeader(
                        userEmail: authViewModel.userEmail,
                        userName: authViewModel.userName,
                        onProfileTap: _openProfileScreen,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: DashboardStats(statistics: statistics),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _openProductCatalog,
                            icon: const Icon(Icons.storefront_outlined),
                            label: const Text('Browse Products'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // SearchSectionSliver(
                    //   controller: _searchController,
                    //   searchQuery: _searchQuery,
                    //   onChanged: (value) => setState(() => _searchQuery = value),
                    //   onClear: _clearSearch,
                    // ),
                    SliverToBoxAdapter(
                      child: SearchSection(
                        controller: _searchController,
                        searchQuery: vm.searchQuery,
                        onChanged: vm.setSearchQuery,
                        onClear: () {
                          _searchController.clear();
                          vm.clearSearch();
                        },
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                        child: Row(
                          children: [
                            Text(
                              'Recent Orders',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer.withValues(
                                  alpha: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${filteredOrders.length}',
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ..._buildOrderSlivers(
                      context,
                      orders: orders,
                      filteredOrders: filteredOrders,
                      orderViewModel: orderViewModel,
                    ),
                    const SliverPadding(padding: EdgeInsets.only(bottom: 88)),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildOrderSlivers(
    BuildContext context, {
    required List<OrderModel> orders,
    required List<OrderModel> filteredOrders,
    required OrderViewModel orderViewModel,
  }) {
    if (orders.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            title: 'No orders yet',
            subtitle: 'Tap "Add Order" to create your first order.',
            actionLabel: 'Add Order',
            onAction: () => _showOrderDialog(),
          ),
        ),
      ];
    }

    if (filteredOrders.isEmpty) {
      return [
        const SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            title: 'No matching orders',
            subtitle: 'Try a different customer name.',
            icon: Icons.search_off_rounded,
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList.separated(
          itemCount: filteredOrders.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final order = filteredOrders[index];
            final colorScheme = Theme.of(context).colorScheme;

            return OrderCard(
              order: order,
              statusColor: orderViewModel.statusColor(
                order.status,
                colorScheme,
              ),
              onEdit: () => _showOrderDialog(order: order),
              onDelete: () => _confirmDelete(order),
            );
          },
        ),
      ),
    ];
  }
}
