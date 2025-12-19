import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Reusable Filter Chip Widget
/// Replaces duplicate _buildTabChip/_buildFilterChip across multiple pages
class AppFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final double horizontalPadding;
  final double verticalPadding;
  final double fontSize;
  final double borderRadius;

  const AppFilterChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.horizontalPadding = 20,
    this.verticalPadding = 6,
    this.fontSize = 13,
    this.borderRadius = 30,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Filter Chip Row with horizontal scrolling
class AppFilterChipRow extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;
  final double spacing;
  final EdgeInsetsGeometry padding;

  const AppFilterChipRow({
    super.key,
    required this.labels,
    this.selectedIndex = 0,
    this.onSelected,
    this.spacing = 8,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: labels.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          return Padding(
            padding: EdgeInsets.only(right: index < labels.length - 1 ? spacing : 0),
            child: AppFilterChip(
              label: label,
              isSelected: selectedIndex == index,
              onTap: () => onSelected?.call(index),
            ),
          );
        }).toList(),
      ),
    );
  }
}
