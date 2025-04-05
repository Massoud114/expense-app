import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/category.dart';
import '../models/expense.dart';
import '../database_helper.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final dbHelper = DatabaseHelper();
  List<Category> categories = [];
  List<Expense> expenses = [];
  DateTime startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = await dbHelper.database;
    final categoryResults = await db.query('categories');
    final expenseResults = await db.query(
      'expenses',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
    );
    setState(() {
      categories = categoryResults.map((row) => Category.fromMap(row)).toList();
      expenses = expenseResults.map((row) => Expense.fromMap(row)).toList();
    });
  }

  List<PieChartSectionData> _createChartData() {
    return categories.map((category) {
      final totalAmount = expenses
          .where((expense) => expense.categoryId == category.id)
          .fold(0.0, (sum, expense) => sum + expense.amount);

      return PieChartSectionData(
        value: totalAmount,
        title: '${category.name}\n${totalAmount.toStringAsFixed(2)}',
        color: Colors.primaries[categories.indexOf(category) % Colors.primaries.length],
        radius: 100,
        titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de Bord'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () async {
              final dates = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: DateTimeRange(start: startDate, end: endDate),
              );
              if (dates != null) {
                setState(() {
                  startDate = dates.start;
                  endDate = dates.end;
                });
                _loadData();
              }
            },
          ),
        ],
      ),
      body: categories.isEmpty || expenses.isEmpty
          ? Center(child: Text('Aucune donnée disponible'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Dépenses par Catégorie', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 16),
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: _createChartData(),
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}