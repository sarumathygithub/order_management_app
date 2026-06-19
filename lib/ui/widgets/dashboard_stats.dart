import 'package:flutter/material.dart';

import '../../data/models/order_statistics.dart';

class DashboardStats extends StatelessWidget {
  const DashboardStats({
    super.key,
    required this.statistics,
  });

  final OrderStatistics statistics;

  static const _cardHeight = 106.0;

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatItem(
        icon: Icons.receipt_long_rounded,
        label: 'Total',
        count: statistics.total,
        color: Theme.of(context).colorScheme.primary,
      ),
      _StatItem(
        icon: Icons.hourglass_top_rounded,
        label: 'Pending',
        count: statistics.pending,
        color: Theme.of(context).colorScheme.tertiary,
      ),
      _StatItem(
        icon: Icons.sync_rounded,
        label: 'Processing',
        count: statistics.processing,
        color: const Color(0xFF1565C0),
      ),
      _StatItem(
        icon: Icons.check_circle_outline_rounded,
        label: 'Delivered',
        count: statistics.delivered,
        color: const Color(0xFF2E7D32),
      ),
      _StatItem(
        icon: Icons.cancel_outlined,
        label: 'Cancelled',
        count: statistics.cancelled,
        color: Theme.of(context).colorScheme.error,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;
        final cardWidth = isWide ? 170.0 : 118.0;

        return SizedBox(
          height: _cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            itemCount: stats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return SizedBox(
                width: cardWidth,
                child: _CompactStatCard(
                  item: stats[index],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _StatItem {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int count;
  final Color color;
}

class _CompactStatCard extends StatelessWidget {
  const _CompactStatCard({required this.item});

  final _StatItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: item.color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${item.count}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                ),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
