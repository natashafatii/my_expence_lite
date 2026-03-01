import 'package:flutter/material.dart';
import 'package:my_expense_lite/config/app_routes.dart';
import 'package:my_expense_lite/screens/home_screen.dart';
import 'package:my_expense_lite/screens/add_edit_transaction_screen.dart';
import 'package:my_expense_lite/utils/app_theme.dart';
import 'package:my_expense_lite/models/transaction_model.dart';
import 'package:my_expense_lite/utils/constants.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.home,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.home:
            return MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            );

          case AppRoutes.addTransaction:
            return MaterialPageRoute(
              builder: (context) => const AddEditTransactionScreen(),
            );

          case AppRoutes.editTransaction:
            final transaction = settings.arguments as Transaction;
            return MaterialPageRoute(
              builder: (context) => AddEditTransactionScreen(
                isEditing: true,
                transaction: transaction,
              ),
            );

          default:
            return MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            );
        }
      },
    );
  }
}