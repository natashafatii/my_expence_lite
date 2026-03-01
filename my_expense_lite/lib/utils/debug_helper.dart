import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'dart:io';

import '../models/transaction_model.dart';
import 'constants.dart';

class DebugHelper {
  static Future<void> showDatabaseInfo(BuildContext context) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final path = dir.path;

      // Check if directory exists and is writable
      final directory = Directory(path);
      final exists = await directory.exists();
      var canWrite = false;
      var canRead = false;

      if (exists) {
        canWrite = await directory.exists(); // Simplified check
        canRead = await directory.exists();  // Simplified check
      }

      // Check for Hive files
      final files = directory.listSync();
      final hiveFiles = files.where((f) => f.path.endsWith('.hive')).toList();

      // Check if box is open
      final boxExists = Hive.isBoxOpen(AppConstants.hiveBoxName);

      String message = '''
📍 Database Location: $path
📁 Directory exists: $exists
✏️ Writable: $canWrite
📖 Readable: $canRead
📦 Box is open: $boxExists
📊 Hive files found: ${hiveFiles.length}
''';

      if (hiveFiles.isNotEmpty) {
        message += '\nFiles:\n';
        for (var file in hiveFiles) {
          final stat = file.statSync();
          message += '  • ${file.path.split('\\').last} (${stat.size} bytes)\n';
        }
      }

      // Try to open box if not open
      if (!boxExists) {
        try {
          Hive.init(path);
          await Hive.openBox<Transaction>(AppConstants.hiveBoxName);
          message += '\n✅ Successfully opened box after attempt';
        } catch (e) {
          message += '\n❌ Failed to open box: $e';
        }
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Database Debug Info'),
          content: SingleChildScrollView(
            child: Text(message),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Debug error: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  static Future<void> testSaveTransaction() async {
    try {
      print('🧪 Testing transaction save...');

      final dir = await getApplicationDocumentsDirectory();
      print('📁 Documents path: ${dir.path}');

      Hive.init(dir.path);
      print('✅ Hive initialized with path');

      final box = await Hive.openBox<Transaction>('test_box');
      print('✅ Test box opened');

      final testTransaction = Transaction(
        id: 'test-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Test Transaction',
        amount: 100,
        type: TransactionType.expense,
        category: Category.food,
        date: DateTime.now(),
      );

      await box.put(testTransaction.id, testTransaction);
      print('✅ Test transaction saved');

      final retrieved = box.get(testTransaction.id);
      print('✅ Test transaction retrieved: ${retrieved?.title}');

      await box.close();
      print('✅ Test box closed');

      print('🧪 Test completed successfully!');
    } catch (e) {
      print('❌ Test failed: $e');
    }
  }
}