import 'package:hive/hive.dart';
import 'package:my_expense_lite/models/transaction_model.dart';

class HiveAdapters {
  static void register() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TransactionTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TransactionAdapter());
    }
  }
}