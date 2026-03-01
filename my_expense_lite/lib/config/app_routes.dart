class AppRoutes {
  static const String home = '/';
  static const String addTransaction = '/add';
  static const String editTransaction = '/edit';
  static const String summary = '/summary';
  static const String settings = '/settings';

  // Route titles for AppBar
  static const Map<String, String> routeTitles = {
    home: 'MyExpenseLite',
    addTransaction: 'Add Transaction',
    editTransaction: 'Edit Transaction',
    summary: 'Summary Dashboard',
    settings: 'Settings',
  };

  // Get title for route
  static String getTitle(String route) {
    return routeTitles[route] ?? 'MyExpenseLite';
  }

  // Check if route is add/edit
  static bool isAddOrEdit(String route) {
    return route == addTransaction || route == editTransaction;
  }

  // Check if route is home
  static bool isHome(String route) {
    return route == home;
  }
}