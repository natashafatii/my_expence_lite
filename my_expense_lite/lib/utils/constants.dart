import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'MyExpenseLite';
  static const String hiveBoxName = 'transactions';

  static const List<String> categories = [
    'Food',
    'Travel',
    'Bills',
    'Shopping',
    'Other'
  ];

  static const List<String> transactionTypes = ['Income', 'Expense'];

  static const String currencySymbol = '₹';

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
}

class AppStrings {
  static const String income = 'Income';
  static const String expense = 'Expense';
  static const String balance = 'Balance';
  static const String totalIncome = 'Total Income';
  static const String totalExpense = 'Total Expense';
  static const String addTransaction = 'Add Transaction';
  static const String editTransaction = 'Edit Transaction';
  static const String save = 'Save';
  static const String update = 'Update';
  static const String delete = 'Delete';
  static const String cancel = 'Cancel';
  static const String title = 'Title';
  static const String amount = 'Amount';
  static const String category = 'Category';
  static const String date = 'Date';
  static const String notes = 'Notes';
  static const String search = 'Search transactions...';
  static const String noTransactions = 'No transactions yet';
  static const String noTransactionsDesc = 'Tap + to add your first transaction';
  static const String titleRequired = 'Title is required';
  static const String amountRequired = 'Amount is required';
  static const String amountPositive = 'Amount must be greater than 0';
  static const String futureDateError = 'Date cannot be in the future';
  static const String clearFilters = 'Clear Filters';
  static const String filterBy = 'Filter by';
  static const String all = 'All';
  static const String recentTransactions = 'Recent Transactions';
  static const String viewAll = 'View All';
}

class AppColors {
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8F8AFF);
  static const Color primaryDark = Color(0xFF4A42E8);
  static const Color income = Color(0xFF4CAF50);
  static const Color expense = Color(0xFFF44336);
  static const Color background = Color(0xFFF8F9FA);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFFFA000);
  static const Color info = Color(0xFF1976D2);

  // Category colors
  static const Color food = Color(0xFFFF9800);
  static const Color travel = Color(0xFF2196F3);
  static const Color bills = Color(0xFFF44336);
  static const Color shopping = Color(0xFF9C27B0);
  static const Color other = Color(0xFF9E9E9E);
}