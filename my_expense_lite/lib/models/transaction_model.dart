import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense
}

@HiveType(typeId: 1)
enum Category {
  @HiveField(0)
  food,
  @HiveField(1)
  travel,
  @HiveField(2)
  bills,
  @HiveField(3)
  shopping,
  @HiveField(4)
  other
}

@HiveType(typeId: 2)
class Transaction {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final TransactionType type;

  @HiveField(4)
  final Category category;

  @HiveField(5)
  final DateTime date;

  @HiveField(6)
  final String? notes;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.notes,
  });

  // Helper method to get category icon
  IconData get categoryIcon {
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

  // Helper method to get category color
  Color get categoryColor {
    switch (category) {
      case Category.food:
        return Colors.orange;
      case Category.travel:
        return Colors.blue;
      case Category.bills:
        return Colors.red;
      case Category.shopping:
        return Colors.purple;
      case Category.other:
        return Colors.grey;
    }
  }

  String get formattedAmount {
    final sign = type == TransactionType.income ? '+' : '-';
    return '$sign Rs. ${amount.toStringAsFixed(2)}';
  }

  // Helper method to get color based on type
  Color get amountColor {
    return type == TransactionType.income
        ? Colors.green.shade700
        : Colors.red.shade700;
  }
}