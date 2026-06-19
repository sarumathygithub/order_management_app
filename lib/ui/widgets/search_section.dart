// import 'package:flutter/material.dart';
//
// class SearchSection extends StatelessWidget {
//   const SearchSection({
//     super.key,
//     required this.controller,
//     required this.searchQuery,
//     required this.onChanged,
//     required this.onClear,
//   });
//
//   final TextEditingController controller;
//   final String searchQuery;
//   final ValueChanged<String> onChanged;
//   final VoidCallback onClear;
//
//   static const double headerHeight = 64;
//
//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//
//     return Container(
//       color: colorScheme.surface,
//       padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
//       child: Container(
//         decoration: BoxDecoration(
//           color: colorScheme.surfaceContainerLowest,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: colorScheme.outlineVariant.withValues(alpha: 0.45),
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: colorScheme.shadow.withValues(alpha: 0.04),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: SearchBar(
//           controller: controller,
//           hintText: 'Search by customer name',
//           hintStyle: WidgetStatePropertyAll(
//             TextStyle(
//               color: colorScheme.onSurfaceVariant,
//               fontSize: 14,
//             ),
//           ),
//           leading: Icon(
//             Icons.search_rounded,
//             color: colorScheme.primary,
//             size: 22,
//           ),
//           trailing: searchQuery.isNotEmpty
//               ? [
//                   IconButton(
//                     icon: const Icon(Icons.clear_rounded, size: 20),
//                     tooltip: 'Clear search',
//                     onPressed: onClear,
//                   ),
//                 ]
//               : null,
//           onChanged: onChanged,
//           backgroundColor: WidgetStatePropertyAll(Colors.transparent),
//           elevation: const WidgetStatePropertyAll(0),
//           padding: const WidgetStatePropertyAll(
//             EdgeInsets.symmetric(horizontal: 4),
//           ),
//           shape: WidgetStatePropertyAll(
//             RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// /// Pins the search bar while scrolling orders — presentation-only wrapper.
// class SearchSectionSliver extends StatelessWidget {
//   const SearchSectionSliver({
//     super.key,
//     required this.controller,
//     required this.searchQuery,
//     required this.onChanged,
//     required this.onClear,
//   });
//
//   final TextEditingController controller;
//   final String searchQuery;
//   final ValueChanged<String> onChanged;
//   final VoidCallback onClear;
//
//   @override
//   Widget build(BuildContext context) {
//     return SliverPersistentHeader(
//       pinned: true,
//       delegate: _SearchSectionDelegate(
//         controller: controller,
//         searchQuery: searchQuery,
//         onChanged: onChanged,
//         onClear: onClear,
//       ),
//     );
//   }
// }
//
// class _SearchSectionDelegate extends SliverPersistentHeaderDelegate {
//   _SearchSectionDelegate({
//     required this.controller,
//     required this.searchQuery,
//     required this.onChanged,
//     required this.onClear,
//   });
//
//   final TextEditingController controller;
//   final String searchQuery;
//   final ValueChanged<String> onChanged;
//   final VoidCallback onClear;
//
//   @override
//   double get minExtent => SearchSection.headerHeight;
//
//   @override
//   double get maxExtent => SearchSection.headerHeight;
//
//   @override
//   Widget build(
//     BuildContext context,
//     double shrinkOffset,
//     bool overlapsContent,
//   ) {
//     final colorScheme = Theme.of(context).colorScheme;
//
//     return Material(
//       color: colorScheme.surface,
//       elevation: overlapsContent ? 1.5 : 0,
//       shadowColor: colorScheme.shadow.withValues(alpha: 0.12),
//       child: SearchSection(
//         controller: controller,
//         searchQuery: searchQuery,
//         onChanged: onChanged,
//         onClear: onClear,
//       ),
//     );
//   }
//
//   @override
//   bool shouldRebuild(covariant _SearchSectionDelegate oldDelegate) {
//     return oldDelegate.searchQuery != searchQuery;
//   }
// }

import 'package:flutter/material.dart';

class SearchSection extends StatelessWidget {
  const SearchSection({
    super.key,
    required this.controller,
    required this.searchQuery,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String searchQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SearchBar(
          controller: controller,
          hintText: 'Search by customer name',
          hintStyle: WidgetStatePropertyAll(
            TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          leading: Icon(
            Icons.search_rounded,
            color: colorScheme.primary,
          ),
          trailing: searchQuery.isNotEmpty
              ? [
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.clear_rounded),
            ),
          ]
              : null,
          onChanged: onChanged,
          backgroundColor: const WidgetStatePropertyAll(
            Colors.transparent,
          ),
          elevation: const WidgetStatePropertyAll(0),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 4),
          ),
        ),
      ),
    );
  }
}