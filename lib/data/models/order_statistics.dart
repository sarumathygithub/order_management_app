class OrderStatistics {
  const OrderStatistics({
    required this.total,
    required this.pending,
    required this.processing,
    required this.delivered,
    required this.cancelled,
  });

  final int total;
  final int pending;
  final int processing;
  final int delivered;
  final int cancelled;

  static const empty = OrderStatistics(
    total: 0,
    pending: 0,
    processing: 0,
    delivered: 0,
    cancelled: 0,
  );
}
