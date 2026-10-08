import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../core/constants/categories.dart';
import '../models/category_item.dart';
import '../models/transaction_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  // In-memory cache & fallback for Web / uninitialized SQLite
  final List<TransactionModel> _inMemoryTransactions = [];
  final List<CategoryItem> _inMemoryCategories = List.from(CategoryItem.defaultCategories);
  bool _useInMemory = kIsWeb;
  int _nextId = 100;

  DatabaseService._init();

  Future<void> init() async {
    if (kIsWeb) {
      _useInMemory = true;
      await seedSampleDataIfEmpty();
      return;
    }

    try {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      final dbPath = await getApplicationDocumentsDirectory();
      final path = join(dbPath.path, 'viet_expenses.db');
      _database = await openDatabase(
        path,
        version: 2,
        onCreate: _createDB,
        onUpgrade: _onUpgradeDB,
      );
      _useInMemory = false;
      await _seedDefaultCategoriesIfEmpty();
    } catch (e) {
      debugPrint('SQLite initialization error, falling back to in-memory store: $e');
      _useInMemory = true;
    }

    await seedSampleDataIfEmpty();
  }

  Future<Database?> get database async {
    if (_useInMemory) return null;
    if (_database != null) return _database!;
    await init();
    return _database;
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        store_or_recipient TEXT NOT NULL,
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        note TEXT,
        transaction_code TEXT,
        payment_method TEXT NOT NULL,
        image_path TEXT,
        raw_text TEXT,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_transactions_date ON transactions(date)');
    await db.execute('CREATE INDEX idx_transactions_category ON transactions(category)');

    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon_code INTEGER NOT NULL,
        color_value INTEGER NOT NULL,
        is_custom INTEGER NOT NULL DEFAULT 0,
        keywords TEXT
      )
    ''');
  }

  Future<void> _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS categories (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          icon_code INTEGER NOT NULL,
          color_value INTEGER NOT NULL,
          is_custom INTEGER NOT NULL DEFAULT 0,
          keywords TEXT
        )
      ''');
    }
  }

  Future<void> _seedDefaultCategoriesIfEmpty() async {
    if (_database == null) return;
    final count = Sqflite.firstIntValue(await _database!.rawQuery('SELECT COUNT(*) FROM categories')) ?? 0;
    if (count == 0) {
      final batch = _database!.batch();
      for (final cat in CategoryItem.defaultCategories) {
        batch.insert('categories', cat.toMap());
      }
      await batch.commit(noResult: true);
    }
  }

  // --- CATEGORIES OPERATIONS ---

  Future<List<CategoryItem>> getAllCategories() async {
    if (_useInMemory || _database == null) {
      return List<CategoryItem>.from(_inMemoryCategories);
    }

    try {
      final db = _database!;
      final result = await db.query('categories');
      if (result.isEmpty) {
        await _seedDefaultCategoriesIfEmpty();
        return List<CategoryItem>.from(_inMemoryCategories);
      }
      return result.map((json) => CategoryItem.fromMap(json)).toList();
    } catch (e) {
      debugPrint('Query categories error: $e');
      return List<CategoryItem>.from(_inMemoryCategories);
    }
  }

  Future<void> addCategory(CategoryItem item) async {
    if (_useInMemory || _database == null) {
      _inMemoryCategories.add(item);
      return;
    }

    try {
      final db = _database!;
      await db.insert('categories', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      _inMemoryCategories.add(item);
    }
  }

  Future<void> updateCategory(CategoryItem item) async {
    if (_useInMemory || _database == null) {
      final idx = _inMemoryCategories.indexWhere((c) => c.id == item.id);
      if (idx != -1) {
        _inMemoryCategories[idx] = item;
      }
      return;
    }

    try {
      final db = _database!;
      await db.update(
        'categories',
        item.toMap(),
        where: 'id = ?',
        whereArgs: [item.id],
      );
    } catch (e) {
      debugPrint('Update category error: $e');
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    if (_useInMemory || _database == null) {
      _inMemoryCategories.removeWhere((c) => c.id == categoryId);
      return;
    }

    try {
      final db = _database!;
      await db.delete(
        'categories',
        where: 'id = ?',
        whereArgs: [categoryId],
      );
    } catch (e) {
      _inMemoryCategories.removeWhere((c) => c.id == categoryId);
    }
  }

  Future<int> getTransactionCountForCategory(String categoryName) async {
    if (_useInMemory || _database == null) {
      return _inMemoryTransactions.where((t) => t.category.displayName.toLowerCase() == categoryName.toLowerCase() || t.category.name.toLowerCase() == categoryName.toLowerCase()).length;
    }

    try {
      final db = _database!;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM transactions WHERE category = ? OR category LIKE ?',
        [categoryName, '%$categoryName%'],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // --- CRUD OPERATIONS ---

  Future<int> insertTransaction(TransactionModel item) async {
    if (_useInMemory || _database == null) {
      final newId = _nextId++;
      final newItem = item.copyWith(id: newId);
      _inMemoryTransactions.insert(0, newItem);
      return newId;
    }

    try {
      final db = _database!;
      return await db.insert('transactions', item.toMap());
    } catch (e) {
      debugPrint('Insert error: $e');
      final newId = _nextId++;
      _inMemoryTransactions.insert(0, item.copyWith(id: newId));
      return newId;
    }
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    if (_useInMemory || _database == null) {
      final list = List<TransactionModel>.from(_inMemoryTransactions);
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    }

    try {
      final db = _database!;
      final result = await db.query('transactions', orderBy: 'date DESC');
      return result.map((json) => TransactionModel.fromMap(json)).toList();
    } catch (e) {
      debugPrint('Query error: $e');
      return List<TransactionModel>.from(_inMemoryTransactions);
    }
  }

  Future<int> updateTransaction(TransactionModel item) async {
    if (_useInMemory || _database == null) {
      final idx = _inMemoryTransactions.indexWhere((t) => t.id == item.id);
      if (idx != -1) {
        _inMemoryTransactions[idx] = item;
        return 1;
      }
      return 0;
    }

    try {
      final db = _database!;
      return await db.update(
        'transactions',
        item.toMap(),
        where: 'id = ?',
        whereArgs: [item.id],
      );
    } catch (e) {
      return 0;
    }
  }

  Future<int> deleteTransaction(int id) async {
    if (_useInMemory || _database == null) {
      _inMemoryTransactions.removeWhere((t) => t.id == id);
      return 1;
    }

    try {
      final db = _database!;
      return await db.delete(
        'transactions',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      _inMemoryTransactions.removeWhere((t) => t.id == id);
      return 1;
    }
  }

  double _monthlyBudget = 10000000.0; // Default 10.000.000 VND

  Future<double> getMonthlyBudget() async {
    if (_useInMemory || _database == null) {
      return _monthlyBudget;
    }
    try {
      final db = _database!;
      final res = await db.rawQuery("SELECT value FROM settings WHERE key = 'monthly_budget'");
      if (res.isNotEmpty && res.first['value'] != null) {
        return double.tryParse(res.first['value'] as String) ?? _monthlyBudget;
      }
      return _monthlyBudget;
    } catch (e) {
      return _monthlyBudget;
    }
  }

  Future<void> setMonthlyBudget(double amount) async {
    _monthlyBudget = amount;
    if (_useInMemory || _database == null) return;
    try {
      final db = _database!;
      await db.execute('''
        CREATE TABLE IF NOT EXISTS settings (
          key TEXT PRIMARY KEY,
          value TEXT
        )
      ''');
      await db.rawInsert(
        'INSERT OR REPLACE INTO settings (key, value) VALUES (?, ?)',
        ['monthly_budget', amount.toString()],
      );
    } catch (e) {
      debugPrint('Error setting monthly budget: $e');
    }
  }

  Future<double> getMonthlySpending(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 1).subtract(const Duration(milliseconds: 1));

    if (_useInMemory || _database == null) {
      return _inMemoryTransactions
          .where((t) => t.date.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) && t.date.isBefore(endOfMonth.add(const Duration(seconds: 1))))
          .fold<double>(0.0, (sum, t) => sum + t.amount);
    }

    try {
      final db = _database!;
      final startStr = startOfMonth.toIso8601String();
      final endStr = endOfMonth.toIso8601String();
      final result = await db.rawQuery(
        'SELECT SUM(amount) as total FROM transactions WHERE date >= ? AND date <= ?',
        [startStr, endStr],
      );
      final total = result.first['total'];
      return (total != null) ? (total as num).toDouble() : 0.0;
    } catch (e) {
      return _inMemoryTransactions
          .where((t) => t.date.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) && t.date.isBefore(endOfMonth.add(const Duration(seconds: 1))))
          .fold<double>(0.0, (sum, t) => sum + t.amount);
    }
  }

  Future<double> getTotalSpending() async {
    if (_useInMemory || _database == null) {
      return _inMemoryTransactions.fold<double>(0.0, (sum, t) => sum + t.amount);
    }

    try {
      final db = _database!;
      final result = await db.rawQuery('SELECT SUM(amount) as total FROM transactions');
      final total = result.first['total'];
      return (total != null) ? (total as num).toDouble() : 0.0;
    } catch (e) {
      return _inMemoryTransactions.fold<double>(0.0, (sum, t) => sum + t.amount);
    }
  }

  // --- AGGREGATIONS FOR CHARTS ---

  Future<Map<ExpenseCategory, double>> getCategoryBreakdown() async {
    if (_useInMemory || _database == null) {
      final Map<ExpenseCategory, double> breakdown = {};
      for (final t in _inMemoryTransactions) {
        breakdown[t.category] = (breakdown[t.category] ?? 0.0) + t.amount;
      }
      return breakdown;
    }

    try {
      final db = _database!;
      final result = await db.rawQuery('''
        SELECT category, SUM(amount) as total
        FROM transactions
        GROUP BY category
        ORDER BY total DESC
      ''');

      final Map<ExpenseCategory, double> breakdown = {};
      for (final row in result) {
        final cat = ExpenseCategoryExt.fromString(row['category'] as String?);
        final total = (row['total'] as num).toDouble();
        breakdown[cat] = total;
      }
      return breakdown;
    } catch (e) {
      final Map<ExpenseCategory, double> breakdown = {};
      for (final t in _inMemoryTransactions) {
        breakdown[t.category] = (breakdown[t.category] ?? 0.0) + t.amount;
      }
      return breakdown;
    }
  }

  Future<List<Map<String, dynamic>>> getDailySpending({int days = 7}) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days - 1));

    if (_useInMemory || _database == null) {
      final Map<String, double> map = {};
      for (final t in _inMemoryTransactions) {
        final key = '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}-${t.date.day.toString().padLeft(2, '0')}';
        map[key] = (map[key] ?? 0.0) + t.amount;
      }

      final List<Map<String, dynamic>> dailyList = [];
      for (int i = 0; i < days; i++) {
        final d = startDate.add(Duration(days: i));
        final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        dailyList.add({
          'date': d,
          'day_str': key,
          'amount': map[key] ?? 0.0,
        });
      }
      return dailyList;
    }

    try {
      final db = _database!;
      final startDateStr = DateTime(startDate.year, startDate.month, startDate.day).toIso8601String();

      final result = await db.rawQuery('''
        SELECT substr(date, 1, 10) as day_str, SUM(amount) as total
        FROM transactions
        WHERE date >= ?
        GROUP BY substr(date, 1, 10)
        ORDER BY day_str ASC
      ''', [startDateStr]);

      final Map<String, double> map = {};
      for (final row in result) {
        map[row['day_str'] as String] = (row['total'] as num).toDouble();
      }

      final List<Map<String, dynamic>> dailyList = [];
      for (int i = 0; i < days; i++) {
        final d = startDate.add(Duration(days: i));
        final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        dailyList.add({
          'date': d,
          'day_str': key,
          'amount': map[key] ?? 0.0,
        });
      }
      return dailyList;
    } catch (e) {
      return [];
    }
  }

  Future<void> seedSampleDataIfEmpty() async {
    if (_useInMemory) {
      if (_inMemoryTransactions.isNotEmpty) return;
    } else if (_database != null) {
      final count = Sqflite.firstIntValue(await _database!.rawQuery('SELECT COUNT(*) FROM transactions')) ?? 0;
      if (count > 0) return;
    }

    final now = DateTime.now();
    final samples = [
      TransactionModel(
        amount: 65000,
        storeOrRecipient: 'HIGHLANDS COFFEE',
        date: now.subtract(const Duration(hours: 2)),
        category: ExpenseCategory.food,
        note: '2 Phin sữa đá cỡ lớn',
        transactionCode: 'VCB29837189',
        paymentMethod: 'VietQR / QR Code',
      ),
      TransactionModel(
        amount: 145000,
        storeOrRecipient: 'WINMART VINHOMES',
        date: now.subtract(const Duration(days: 1, hours: 3)),
        category: ExpenseCategory.shopping,
        note: 'Sữa tươi, bánh mì, snack',
        transactionCode: 'TCB90182741',
        paymentMethod: 'Chuyển khoản Banking',
      ),
      TransactionModel(
        amount: 52000,
        storeOrRecipient: 'XANH SM BIKE',
        date: now.subtract(const Duration(days: 2, hours: 5)),
        category: ExpenseCategory.transport,
        note: 'Đi làm từ nhà đến công ty',
        transactionCode: 'MB89123847',
        paymentMethod: 'VietQR / QR Code',
      ),
      TransactionModel(
        amount: 380000,
        storeOrRecipient: 'ĐIỆN LỰC EVN HANOI',
        date: now.subtract(const Duration(days: 3, hours: 1)),
        category: ExpenseCategory.utilities,
        note: 'Tiền điện tháng này',
        transactionCode: 'VNPAY554129',
        paymentMethod: 'Ví điện tử',
      ),
      TransactionModel(
        amount: 85000,
        storeOrRecipient: 'CƠM TẤM PHÚC LỘC THỌ',
        date: now.subtract(const Duration(days: 4, hours: 6)),
        category: ExpenseCategory.food,
        note: 'Cơm sườn bì chả + canh rong biển',
        transactionCode: 'TPB98127391',
        paymentMethod: 'VietQR / QR Code',
      ),
      TransactionModel(
        amount: 250000,
        storeOrRecipient: 'NGUYEN VAN HOANG',
        date: now.subtract(const Duration(days: 5, hours: 4)),
        category: ExpenseCategory.personal,
        note: 'Góp tiền quỹ ăn trưa nhóm',
        transactionCode: 'MB77412891',
        paymentMethod: 'Chuyển khoản Banking',
      ),
    ];

    for (final s in samples) {
      await insertTransaction(s);
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
