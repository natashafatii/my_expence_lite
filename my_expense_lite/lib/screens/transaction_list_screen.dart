import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:my_expense_lite/providers/transaction_provider.dart';
import 'package:my_expense_lite/widgets/transaction_card.dart';
import 'package:my_expense_lite/widgets/custom_search_bar.dart';
import 'package:my_expense_lite/widgets/filter_chips.dart';
import 'package:my_expense_lite/widgets/empty_state_widget.dart';
import 'package:my_expense_lite/utils/constants.dart';
import 'package:my_expense_lite/utils/date_formatter.dart';
import 'package:my_expense_lite/utils/currency_formatter.dart';
import '../models/transaction_model.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final transactions = provider.transactions;
        final hasActiveFilters = provider.selectedType != null ||
            provider.selectedCategory != null ||
            provider.searchQuery.isNotEmpty;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // Search Bar - Fixed at top
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: CustomSearchBar(
                    onSearch: (query) => provider.setSearchQuery(query),
                  ),
                ),

                // Filter Chips - Fixed below search
                if (hasActiveFilters || transactions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: FilterChips(
                      selectedType: provider.selectedType,
                      selectedCategory: provider.selectedCategory,
                      onTypeSelected: (type) => provider.setTypeFilter(type),
                      onCategorySelected: (category) => provider.setCategoryFilter(category),
                      onClear: () => provider.clearFilters(),
                    ),
                  ),

                // Scrollable Content
                Expanded(
                  child: transactions.isEmpty
                      ? const EmptyStateWidget()
                      : _buildTransactionList(transactions, provider, context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionList(
      List<Transaction> transactions,
      TransactionProvider provider,
      BuildContext context,
      ) {
    // Group transactions by date (Today, Yesterday, This Week, Older)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    final Map<String, List<Transaction>> grouped = {
      'Today': [],
      'Yesterday': [],
      'This Week': [],
      'Older': [],
    };

    for (var transaction in transactions) {
      final transactionDate = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );

      if (transactionDate == today) {
        grouped['Today']!.add(transaction);
      } else if (transactionDate == yesterday) {
        grouped['Yesterday']!.add(transaction);
      } else if (transactionDate.isAfter(weekAgo)) {
        grouped['This Week']!.add(transaction);
      } else {
        grouped['Older']!.add(transaction);
      }
    }

    // Remove empty groups
    grouped.removeWhere((key, value) => value.isEmpty);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      children: [
        // Summary Chip
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${transactions.length} Transactions',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              Row(
                children: [
                  _buildSummaryIndicator(
                    color: Colors.green,
                    amount: provider.totalIncome,
                    label: 'In',
                  ),
                  const SizedBox(width: 12),
                  _buildSummaryIndicator(
                    color: Colors.red,
                    amount: provider.totalExpense,
                    label: 'Out',
                  ),
                ],
              ),
            ],
          ),
        ),

        // Grouped Transactions
        ...grouped.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${entry.value.length})',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              ...entry.value.map((transaction) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TransactionCard(
                  transaction: transaction,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/edit',
                      arguments: transaction,
                    );
                  },
                  onDelete: () => _showDeleteDialog(context, provider, transaction),
                ),
              )),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSummaryIndicator({
    required Color color,
    required double amount,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Rs. ${amount.toStringAsFixed(0)}', // Changed from ₹ to Rs.
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context,
      TransactionProvider provider,
      Transaction transaction,
      ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Delete Transaction',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you sure you want to delete "${transaction.title}"?',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: transaction.categoryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        transaction.categoryIcon,
                        color: transaction.categoryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            transaction.formattedAmount, // This will use Rs. from the model
                            style: TextStyle(
                              color: transaction.amountColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await provider.deleteTransaction(transaction.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Transaction deleted'),
                      backgroundColor: Colors.green.shade600,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}