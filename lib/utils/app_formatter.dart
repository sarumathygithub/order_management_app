import 'package:intl/intl.dart';


class AppFormatter {
  AppFormatter._();

  static final NumberFormat priceFormat =
  NumberFormat('#,##,##0.00', 'en_IN');

  static final DateFormat dateFormat =
  DateFormat('dd MMM yyyy');
}