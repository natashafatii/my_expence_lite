import 'package:flutter/material.dart';
import 'package:my_expense_lite/models/transaction_model.dart';
import 'package:my_expense_lite/database/hive_service.dart';
import 'package:uuid/uuid.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  List<Transaction> _filteredTransactions = [];

  String _searchQuery = '';
  TransactionType? _selectedType;
  Category? _selectedCategory;

  List<Transaction> get transactions => _filteredTransactions.isEmpty
      ? _transactions
      : _filteredTransactions;

  String get searchQuery => _searchQuery;
  TransactionType? get selectedType => _selectedType;
  Category? get selectedCategory => _selectedCategory;

  TransactionProvider() {
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      _transactions = HiveService.getAllTransactions();
      _applyFilters();
      notifyListeners();
      print('📊 Loaded ${_transactions.length} transactions');
    } catch (e) {
      print('❌ Error loading transactions: $e');
    }
  }

  Future<void> addTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    required Category category,
    required DateTime date,
    String? notes,
  }) async {
    try {
      final transaction = Transaction(
        id: const Uuid().v4(),
        title: title,
        amount: amount,
        type: type,
        category: category,
        date: date,
        notes: notes,
      );

      await HiveService.addTransaction(transaction);
      await _loadTransactions(); // Reload from database
    } catch (e) {
      print('❌ Error in addTransaction: $e');
      rethrow;
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await HiveService.updateTransaction(transaction);
      await _loadTransactions();
    } catch (e) {
      print('❌ Error in updateTransaction: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await HiveService.deleteTransaction(id);
      await _loadTransactions();
    } catch (e) {
      print('❌ Error in deleteTransaction: $e');
      rethrow;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  void setTypeFilter(TransactionType? type) {
    _selectedType = _selectedType == type ? null : type;
    _applyFilters();
  }

  void setCategoryFilter(Category? category) {
    _selectedCategory = _selectedCategory == category ? null : category;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedType = null;
    _selectedCategory = null;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredTransactions = _transactions.where((transaction) {
      if (_searchQuery.isNotEmpty &&
          !transaction.title.toLowerCase().contains(_searchQuery)) {
        return false;
      }
      if (_selectedType != null && transaction.type != _selectedType) {
        return false;
      }
      if (_selectedCategory != null && transaction.category != _selectedCategory) {
        return false;
      }
      return true;
    }).toList();

    notifyListeners();
  }

  double get totalIncome {
    return _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get balance => totalIncome - totalExpense;

  List<Transaction> getIncomeTransactions() {
    return _transactions.where((t) => t.type == TransactionType.income).toList();
  }

  List<Transaction> getExpenseTransactions() {
    return _transactions.where((t) => t.type == TransactionType.expense).toList();
  }

  List<Transaction> getRecentTransactions() {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _transactions.where((t) => t.date.isAfter(weekAgo)).toList();
  }
}