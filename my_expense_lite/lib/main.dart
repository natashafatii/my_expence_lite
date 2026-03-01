import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:my_expense_lite/database/hive_adapters.dart';
import 'package:my_expense_lite/database/hive_service.dart';
import 'package:my_expense_lite/providers/transaction_provider.dart';
import 'package:my_expense_lite/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('=' * 50);
  print('🚀 STARTING APP INITIALIZATION');
  print('=' * 50);

  try {
    // Step 1: Initialize Hive
    print('📦 Initializing Hive...');
    await Hive.initFlutter();
    print('✅ Hive initialized');

    // Step 2: Register adapters
    print('📝 Registering Hive adapters...');
    HiveAdapters.register();
    print('✅ Hive adapters registered');

    // Step 3: Initialize HiveService (THIS IS THE CRITICAL STEP)
    print('🔧 Initializing HiveService...');
    await HiveService.init();
    print('✅ HiveService initialized successfully');

    // Step 4: Run the app
    print('🎯 Starting Flutter app...');
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => TransactionProvider(),
          ),
        ],
        child: const App(),
      ),
    );

    print('=' * 50);
    print('🎉 APP STARTED SUCCESSFULLY');
    print('=' * 50);

  } catch (e, stackTrace) {
    print('=' * 50);
    print('❌ FATAL ERROR DURING INITIALIZATION');
    print('=' * 50);
    print('Error: $e');
    print('StackTrace: $stackTrace');

    // Show error screen
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Failed to Initialize Database',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Error: $e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Restart the app
                    main();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}