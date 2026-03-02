# 📱 MyExpenseLite

A beautiful, feature-rich offline expense tracker built with Flutter. Track your income and expenses with ease!

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg) ![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg) ![License](https://img.shields.io/badge/license-MIT-green.svg)

---


## ✨ Features

### 💰 Transaction Management
- ✅ Add Transaction – Record income and expenses with details
- ✅ Edit Transaction – Modify existing entries
- ✅ Delete Transaction – Remove with confirmation dialog
- ✅ View List – Transactions grouped by Today, Yesterday, This Week, Older

### 📊 Financial Overview
- ✅ Dashboard – Quick view of total balance, income, and expense
- ✅ Summary Screen – Visual analytics with charts and insights
- ✅ Category Breakdown – Spending patterns by category with progress bars
- ✅ Recent Activity – Last 5 transactions displayed

### 🔍 Search & Filter
- ✅ Search by Title – Real-time search as you type
- ✅ Filter by Type – Toggle between Income (green) and Expense (red)
- ✅ Filter by Category – Food, Travel, Bills, Shopping, Other
- ✅ Clear Filters – One-tap reset

### 📈 Analytics & Insights
- ✅ Income vs Expense Pie Chart – Visual comparison with percentages
- ✅ Monthly Bar Chart – 6-month spending trends
- ✅ Category Analysis – Progress bars with percentages
- ✅ Financial Insights – Daily average, savings rate, top category

### 💾 Local Database
- ✅ 100% Offline – All data stored locally
- ✅ Hive Database – Fast, lightweight, reliable
- ✅ Persistent Storage – Data survives app restarts
- ✅ Export to JSON – Backup your data anytime

### 🎨 UI/UX Highlights
- ✅ Modern Design – Clean, professional interface
- ✅ Gradient Cards – Visual appeal with smooth gradients
- ✅ Empty States – Beautiful placeholders when no data
- ✅ Responsive – Works on phones and tablets
- ✅ PKR Currency – Pakistani Rupee support

---



## 🛠️ Technologies Used

| Technology | Purpose |
|------------|---------|
| Flutter    | UI Framework |
| Dart       | Programming Language |
| Hive       | Local NoSQL Database |
| Provider   | State Management |
| FL Chart   | Charts & Graphs |
| Intl       | Date Formatting |
| Path Provider | File System Access |
| Share Plus | JSON Export |
| UUID       | Unique ID Generation |

---

## 📦 Installation

### Prerequisites
- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio / VS Code

### Steps
1. **Clone the repository**
```bash
git clone https://github.com/natashafatii/my_expense_lite.git
 ```
2. **Navigate to project directory**
 ```bash
cd my_expense_lite
 ```
3. **Install dependencies**
```bash
flutter pub get
```
4. **Generate Hive adapters**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
5. **Run the app**
```bash
flutter run
```
