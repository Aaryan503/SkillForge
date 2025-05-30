import 'package:flutter/material.dart';

class SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController controller;
  final VoidCallback? onChanged;

  SearchBarDelegate({
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          controller: controller,
          onChanged: (_) => onChanged?.call(),
          decoration: const InputDecoration(
            hintText: 'Search challenges...',
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 64;

  @override
  double get minExtent => 64;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}