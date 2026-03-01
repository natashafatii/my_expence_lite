import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:my_expense_lite/providers/transaction_provider.dart';
import 'package:my_expense_lite/screens/transaction_list_screen.dart';
import 'package:my_expense_lite/screens/summary_screen.dart';
import 'package:my_expense_lite/utils/constants.dart';
import 'package:my_expense_lite/utils/currency_formatter.dart';
import 'package:my_expense_lite/utils/debug_helper.dart';
import 'package:my_expense_lite/database/hive_service.dart';
import 'package:my_expense_lite/models/transaction_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (mounted) {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  // JSON Export Function
  Future<void> _exportToJson() async {
    try {
      final transactions = HiveService.getAllTransactions();

      if (transactions.isEmpty) {
        _showMessage('No transactions to export', Colors.orange);
        return;
      }

      final jsonData = transactions.map((t) => {
        'id': t.id,
        'title': t.title,
        'amount': t.amount,
        'type': t.type == TransactionType.income ? 'Income' : 'Expense',
        'category': _getCategoryName(t.category),
        'date': '${t.date.day}/${t.date.month}/${t.date.year}',
        'time': '${t.date.hour}:${t.date.minute}',
        'notes': t.notes ?? '',
      }).toList();

      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'transactions_export_${DateTime.now().millisecondsSinceEpoch}.json';
      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);

      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(jsonData),
        encoding: utf8,
      );

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('✅ Export Successful'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📊 Exported ${transactions.length} transactions'),
                const SizedBox(height: 12),
                const Text('File saved to:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    filePath,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                const SizedBox(height: 8),
                Text('File name: $fileName', style: const TextStyle(fontSize: 12)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _openFileLocation(filePath);
                },
                child: const Text('Open Folder'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _showMessage('Error exporting: $e', Colors.red);
    }
  }

  // View All Transactions Function
  void _viewAllTransactions() {
    final transactions = HiveService.getAllTransactions();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.list_alt, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('All Transactions (${transactions.length})'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: transactions.isEmpty
              ? const Center(child: Text('No transactions found'))
              : ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final t = transactions[index];
              return Card(
                margin: const EdgeInsets.all(4),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(t.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(t.category),
                      color: _getCategoryColor(t.category),
                      size: 16,
                    ),
                  ),
                  title: Text(t.title),
                  subtitle: Text(
                    '${t.date.day}/${t.date.month}/${t.date.year}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rs. ${t.amount.toStringAsFixed(2)}',  // Changed to Rs.
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: t.type == TransactionType.income ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        t.type == TransactionType.income ? 'INCOME' : 'EXPENSE',
                        style: TextStyle(
                          fontSize: 10,
                          color: t.type == TransactionType.income ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Helper to open file location
  void _openFileLocation(String path) {
    Process.run('explorer.exe', ['/select,', path]);
  }

  // Helper to show messages
  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Helper methods for categories
  String _getCategoryName(Category category) {
    switch (category) {
      case Category.food: return 'Food';
      case Category.travel: return 'Travel';
      case Category.bills: return 'Bills';
      case Category.shopping: return 'Shopping';
      case Category.other: return 'Other';
    }
  }

  IconData _getCategoryIcon(Category category) {
    switch (category) {
      case Category.food: return Icons.restaurant;
      case Category.travel: return Icons.flight;
      case Category.bills: return Icons.receipt;
      case Category.shopping: return Icons.shopping_bag;
      case Category.other: return Icons.category;
    }
  }

  Color _getCategoryColor(Category category) {
    switch (category) {
      case Category.food: return Colors.orange;
      case Category.travel: return Colors.blue;
      case Category.bills: return Colors.red;
      case Category.shopping: return Colors.purple;
      case Category.other: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // Balance Card
            Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                return _buildBalanceCard(provider);
              },
            ),

            // Tab Bar
            _buildTabBar(),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  TransactionListScreen(),
                  SummaryScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add');
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.account_balance_wallet,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            AppConstants.appName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      actions: [
        // Combined Menu Button
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(30),
          ),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.primary),
            tooltip: 'More Options',
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            offset: const Offset(0, 40),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view_all',
                child: Row(
                  children: [
                    Icon(Icons.list_alt, color: Colors.blue, size: 20),
                    SizedBox(width: 12),
                    Text('View All Transactions'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, color: Colors.green, size: 20),
                    SizedBox(width: 12),
                    Text('Export to JSON'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'debug',
                child: Row(
                  children: [
                    Icon(Icons.bug_report, color: Colors.amber, size: 20),
                    SizedBox(width: 12),
                    Text('Debug Database'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'view_all':
                  _viewAllTransactions();
                  break;
                case 'export':
                  _exportToJson();
                  break;
                case 'debug':
                  DebugHelper.showDatabaseInfo(context);
                  break;
              }
            },
          ),
        ),

        // Profile Avatar
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.transparent,
            backgroundImage: const AssetImage('assets/images/profile.png'),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(TransactionProvider provider) {
    final income = provider.totalIncome;
    final expense = provider.totalExpense;
    final balance = provider.balance;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6C63FF),
            Color(0xFF8F8AFF),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rs. ${balance.toStringAsFixed(2)}',  // Changed to Rs.
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildBalanceStat(
                  label: 'Income',
                  amount: income,
                  icon: Icons.arrow_upward,
                ),
              ),
              Container(
                height: 30,
                width: 1,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildBalanceStat(
                  label: 'Expense',
                  amount: expense,
                  icon: Icons.arrow_downward,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceStat({
    required String label,
    required double amount,
    required IconData icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 14,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            Text(
              'Rs. ${amount.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey.shade700,
        tabs: const [
          Tab(
            icon: Icon(Icons.list_alt),
            text: 'Transactions',
          ),
          Tab(
            icon: Icon(Icons.pie_chart),
            text: 'Summary',
          ),
        ],
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }
}