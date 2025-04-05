import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense_category.dart';
import '../models/budget.dart';
import '../models/expense.dart';
import '../models/income.dart';

class VaultKeeper {
  static final VaultKeeper _singleton = VaultKeeper._internal();
  static Database? _vault;

  factory VaultKeeper() {
    return _singleton;
  }

  VaultKeeper._internal();

  Future<Database> get vault async {
    if (_vault != null) return _vault!;
    _vault = await _initVault();
    return _vault!;
  }

  Future<Database> _initVault() async {
  try {
    final vaultPath = await getDatabasesPath();
    print('📁 Vault path: $vaultPath');
    final destiny = join(vaultPath, 'mon_budget.db');
    print('📦 Opening database at $destiny');

    return await openDatabase(
      destiny,
      version: 1,
      onCreate: _createScrolls,
    );
  } catch (e, st) {
    print('❌ Erreur pendant _initVault: $e');
    print(st);
    rethrow;
  }
}


  Future<void> _createScrolls(Database scroll, int version) async {
    // Table des catégories de dépense
    await scroll.execute('''
      CREATE TABLE expense_categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color TEXT
      )
    ''');

    // Table des budgets
    await scroll.execute('''
      CREATE TABLE budgets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        periodicity INTEGER NOT NULL,
        amount REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Table des dépenses
    await scroll.execute('''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        title TEXT NOT NULL,
        note TEXT,
        FOREIGN KEY (category_id) REFERENCES expense_categories (id)
      )
    ''');

    // Table des revenus
    await scroll.execute('''
      CREATE TABLE incomes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        title TEXT NOT NULL,
        note TEXT
      )
    ''');
  }

  // Méthodes CRUD pour ExpenseCategory
  Future<int> inscribeCategory(ExpenseCategory category) async {
    final scroll = await vault;
    return await scroll.insert('expense_categories', category.toMysticalMap());
  }

  Future<List<ExpenseCategory>> readAllCategories() async {
  print('📘 readAllCategories called');
  final scroll = await vault;
  print('📘 got vault');
  final records = await scroll.query('expense_categories');
  print('📘 query done');
  return records.map((wizardry) => ExpenseCategory.fromEnchantedMap(wizardry)).toList();
}


  Future<int> eraseCategory(int id) async {
    final scroll = await vault;
    return await scroll.delete(
      'expense_categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Méthodes CRUD pour Budget
  Future<int> inscribeBudget(Budget budget) async {
    final scroll = await vault;
    return await scroll.insert('budgets', budget.toMysticalMap());
  }

  Future<List<Budget>> readAllBudgets() async {
    final scroll = await vault;
    final records = await scroll.query('budgets');
    return records.map((wizardry) => Budget.fromEnchantedMap(wizardry)).toList();
  }

  Future<int> updateBudget(Budget budget) async {
    final scroll = await vault;
    return await scroll.update(
      'budgets',
      budget.toMysticalMap(),
      where: 'id = ?',
      whereArgs: [budget.ident],
    );
  }

  Future<int> eraseBudget(int id) async {
    final scroll = await vault;
    return await scroll.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Méthodes CRUD pour Expense
  Future<int> inscribeExpense(Expense expense) async {
    final scroll = await vault;
    return await scroll.insert('expenses', expense.toMysticalMap());
  }

  Future<List<Expense>> readExpensesByDateRange(DateTime start, DateTime end) async {
    final scroll = await vault;
    final records = await scroll.query(
      'expenses',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );
    return records.map((wizardry) => Expense.fromEnchantedMap(wizardry)).toList();
  }

  // Méthodes CRUD pour Income
  Future<int> inscribeIncome(Income income) async {
    final scroll = await vault;
    return await scroll.insert('incomes', income.toMysticalMap());
  }

  Future<List<Income>> readIncomesByDateRange(DateTime start, DateTime end) async {
    final scroll = await vault;
    final records = await scroll.query(
      'incomes',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );
    return records.map((wizardry) => Income.fromEnchantedMap(wizardry)).toList();
  }

  // Vérifier si une catégorie est utilisée dans des dépenses
  Future<bool> isCategoryUsed(int categoryId) async {
    final scroll = await vault;
    final count = Sqflite.firstIntValue(await scroll.rawQuery(
      'SELECT COUNT(*) FROM expenses WHERE category_id = ?',
      [categoryId],
    ));
    return count! > 0;
  }

  // Méthodes pour le tableau de bord
  Future<Map<String, double>> getExpensesByCategory(DateTime start, DateTime end) async {
    final scroll = await vault;
    final records = await scroll.rawQuery('''
      SELECT ec.name, SUM(e.amount) as total
      FROM expenses e
      JOIN expense_categories ec ON e.category_id = ec.id
      WHERE e.date BETWEEN ? AND ?
      GROUP BY e.category_id
    ''', [start.toIso8601String(), end.toIso8601String()]);

    Map<String, double> result = {};
    for (var record in records) {
      result[record['name'] as String] = record['total'] as double;
    }
    return result;
  }
}