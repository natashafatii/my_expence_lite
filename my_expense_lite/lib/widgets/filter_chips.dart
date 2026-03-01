import 'package:flutter/material.dart';
import 'package:my_expense_lite/models/transaction_model.dart';
import 'package:my_expense_lite/utils/constants.dart';

class FilterChips extends StatelessWidget {
  final TransactionType? selectedType;
  final Category? selectedCategory;
  final Function(TransactionType?) onTypeSelected;
  final Function(Category?) onCategorySelected;
  final VoidCallback onClear;

  const FilterChips({
    super.key,
    required this.selectedType,
    required this.selectedCategory,
    required this.onTypeSelected,
    required this.onCategorySelected,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type Filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildTypeChip(
                label: 'All',
                isSelected: selectedType == null,
                onTap: () => onTypeSelected(null),
              ),
              const SizedBox(width: 8),
              _buildTypeChip(
                label: AppStrings.income,
                icon: Icons.trending_up,
                color: AppColors.income,
                isSelected: selectedType == TransactionType.income,
                onTap: () => onTypeSelected(TransactionType.income),
              ),
              const SizedBox(width: 8),
              _buildTypeChip(
                label: AppStrings.expense,
                icon: Icons.trending_down,
                color: AppColors.expense,
                isSelected: selectedType == TransactionType.expense,
                onTap: () => onTypeSelected(TransactionType.expense),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Category Filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryChip(
                label: 'All',
                isSelected: selectedCategory == null,
                onTap: () => onCategorySelected(null),
              ),
              const SizedBox(width: 8),
              ...Category.values.map((category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildCategoryChip(
                  label: _getCategoryName(category),
                  icon: _getCategoryIcon(category),
                  color: _getCategoryColor(category),
                  isSelected: selectedCategory == category,
                  onTap: () => onCategorySelected(category),
                ),
              )),
            ],
          ),
        ),

        // Clear Filters Button (if any filter is active)
        if (selectedType != null || selectedCategory != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text(AppStrings.clearFilters),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTypeChip({
    required String label,
    IconData? icon,
    Color? color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      avatar: icon != null ? Icon(icon, size: 16, color: color) : null,
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.grey.shade100,
      selectedColor: (color ?? AppColors.primary).withOpacity(0.2),
      checkmarkColor: color ?? AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? color ?? AppColors.primary : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    IconData? icon,
    Color? color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      avatar: icon != null ? Icon(icon, size: 16, color: color) : null,
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.grey.shade100,
      selectedColor: (color ?? AppColors.primary).withOpacity(0.2),
      checkmarkColor: color ?? AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? color ?? AppColors.primary : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  String _getCategoryName(Category category) {
    switch (category) {
      case Category.food:
        return 'Food';
      case Category.travel:
        return 'Travel';
      case Category.bills:
        return 'Bills';
      case Category.shopping:
        return 'Shopping';
      case Category.other:
        return 'Other';
    }
  }

  IconData _getCategoryIcon(Category category) {
    switch (category) {
      case Category.food:
        return Icons.fastfood;
      case Category.travel:
        return Icons.flight;
      case Category.bills:
        return Icons.receipt;
      case Category.shopping:
        return Icons.shopping_bag;
      case Category.other:
        return Icons.category;
    }
  }

  Color _getCategoryColor(Category category) {
    switch (category) {
      case Category.food:
        return AppColors.food;
      case Category.travel:
        return AppColors.travel;
      case Category.bills:
        return AppColors.bills;
      case Category.shopping:
        return AppColors.shopping;
      case Category.other:
        return AppColors.other;
    }
  }
}