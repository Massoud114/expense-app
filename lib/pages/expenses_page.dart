import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../database_helper.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  _ExpensesPageState createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final dbHelper = DatabaseHelper();
  List<Expense> expenses = [];
  DateTime startDate = DateTime.now().subtract(Duration(days: 7));
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final db = await dbHelper.database;
    final result = await db.query(
      'expenses',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
    );
    setState(() {
      expenses = result.map((row) => Expense.fromMap(row)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Dépenses'),
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
                _loadExpenses();
              }
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          final expense = expenses[index];
          return ListTile(
            title: Text(expense.label),
            subtitle: Text('${expense.amount} - ${expense.date}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddExpensePage()),
          ).then((_) => _loadExpenses());
        },
      ),
    );
  }
}

class AddExpensePage extends StatelessWidget {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _observationController = TextEditingController();
  final dbHelper = DatabaseHelper();

  AddExpensePage({super.key});

  Future<void> _addExpense(
    DateTime date,
    int categoryId,
    double amount,
    String label,
    String? observation,
  ) async {
    final db = await dbHelper.database;
    await db.insert(
      'expenses',
      {
        'date': date.toIso8601String(),
        'categoryId': categoryId,
        'amount': amount,
        'label': label,
        'observation': observation,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nouvelle Dépense')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Montant'),
            ),
            TextField(
              controller: _labelController,
              decoration: InputDecoration(labelText: 'Libellé'),
            ),
            TextField(
              controller: _observationController,
              decoration: InputDecoration(labelText: 'Observation (facultatif)'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(_amountController.text) ?? 0.0;
                final label = _labelController.text;
                final observation = _observationController.text;
                _addExpense(DateTime.now(), 1, amount, label, observation);
                Navigator.pop(context);
              },
              child: Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }
}