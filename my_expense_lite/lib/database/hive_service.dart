import 'package:hive/hive.dart';
import 'package:my_expense_lite/models/transaction_model.dart';
import 'package:my_expense_lite/utils/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class HiveService {
  static Box<Transaction>? _transactionBox;
  static bool _isInitialized = false;

  // Initialize Hive and open box
  static Future<void> init() async {
    try {
      print('🔧 HiveService.init() started...');

      // Get documents directory
      final appDocumentDir = await getApplicationDocumentsDirectory();
      final path = appDocumentDir.path;
      print('📁 Documents path: $path');

      // Ensure directory exists
      final directory = Directory(path);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
        print('📁 Created directory: $path');
      }

      // Initialize Hive with the path
      Hive.init(path);
      print('✅ Hive initialized with path');

      // Register adapters if not already registered
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(TransactionTypeAdapter());
        print('✅ Registered TransactionTypeAdapter');
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(CategoryAdapter());
        print('✅ Registered CategoryAdapter');
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(TransactionAdapter());
        print('✅ Registered TransactionAdapter');
      }

      // Open the box
      print('📦 Opening box: ${AppConstants.hiveBoxName}');
      _transactionBox = await Hive.openBox<Transaction>(AppConstants.hiveBoxName);
      _isInitialized = true;

      print('✅ Box opened successfully');
      print('📊 Current transactions: ${_transactionBox!.length}');

      final files = directory.listSync();
      final hiveFiles = files.where((f) => f.path.endsWith('.hive')).toList();
      print('📂 Hive files found: ${hiveFiles.length}');
      for (var file in hiveFiles) {
        final stat = file.statSync();
        print('   • ${file.path.split('\\').last} (${stat.size} bytes)');
      }

      print('✅ HiveService.init() completed successfully');

    } catch (e, stackTrace) {
      print('❌ ERROR in HiveService.init(): $e');
      print(stackTrace);
      _isInitialized = false;
      rethrow;
    }
  }

  // Get the box with safety check
  static Box<Transaction> getBox() {
    if (!_isInitialized || _transactionBox == null) {
      throw Exception('HiveService not initialized. Call init() first.');
    }
    return _transactionBox!;
  }

  // Check if initialized
  static bool get isInitialized => _isInitialized;

  // Save transaction
  static Future<void> addTransaction(Transaction transaction) async {
    try {
      print('💾 Attempting to save transaction: ${transaction.title}');

      if (!_isInitialized) {
        print('❌ HiveService not initialized! Attempting to reinitialize...');
        await init(); // Try to reinitialize
      }

      if (!_isInitialized) {
        throw Exception('Failed to initialize HiveService');
      }

      await _transactionBox!.put(transaction.id, transaction);
      print('✅ Transaction saved successfully. ID: ${transaction.id}');

      // Verify save
      final saved = _transactionBox!.get(transaction.id);
      if (saved != null) {
        print('✅ Verification: Transaction found in box');
      } else {
        print('❌ Verification: Transaction NOT found');
      }

    } catch (e, stackTrace) {
      print('❌ Error saving transaction: $e');
      print(stackTrace);
      rethrow;
    }
  }

  // Update transaction
  static Future<void> updateTransaction(Transaction transaction) async {
    try {
      if (!_isInitialized) await init();
      await _transactionBox!.put(transaction.id, transaction);
      print('✅ Transaction updated: ${transaction.title}');
    } catch (e) {
      print('❌ Error updating transaction: $e');
      rethrow;
    }
  }

  // Delete transaction
  static Future<void> deleteTransaction(String id) async {
    try {
      if (!_isInitialized) await init();
      await _transactionBox!.delete(id);
      print('✅ Transaction deleted: $id');
    } catch (e) {
      print('❌ Error deleting transaction: $e');
      rethrow;
    }
  }

  // Get all transactions
  static List<Transaction> getAllTransactions() {
    try {
      if (!_isInitialized) {
        print('⚠️ HiveService not initialized, returning empty list');
        return [];
      }
      final transactions = _transactionBox!.values.toList();
      print('📊 Retrieved ${transactions.length} transactions');
      return transactions;
    } catch (e) {
      print('❌ Error getting transactions: $e');
      return [];
    }
  }

  // Get single transaction
  static Transaction? getTransaction(String id) {
    try {
      if (!_isInitialized) return null;
      return _transactionBox!.get(id);
    } catch (e) {
      print('❌ Error getting transaction: $e');
      return null;
    }
  }
}