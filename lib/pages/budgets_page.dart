import 'package:flutter/material.dart';
import '../models/budget.dart';
import '../database_helper.dart';

class BudgetsPage extends StatefulWidget {
  const BudgetsPage({super.key});

  @override
  _BudgetsPageState createState() => _BudgetsPageState();
}

class _BudgetsPageState extends State<BudgetsPage> {
  final dbHelper = DatabaseHelper();
  List<Budget> budgets = [];

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    final db = await dbHelper.database;
    final result = await db.query('budgets');
    setState(() {
      budgets = result.map((row) => Budget.fromMap(row)).toList();
    });
  }

  Future<void> _deleteBudget(int id) async {
    final db = await dbHelper.database;
    await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
    _loadBudgets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Budgets')),
      body: ListView.builder(
        itemCount: budgets.length,
        itemBuilder: (context, index) {
          final budget = budgets[index];
          return ListTile(
            title: Text('${budget.periodicity} - ${budget.amount}'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteBudget(budget.id!),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddBudgetPage()),
          ).then((_) => _loadBudgets());
        },
      ),
    );
  }
}

class AddBudgetPage extends StatelessWidget {
  final TextEditingController _periodicityController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final dbHelper = DatabaseHelper();

  AddBudgetPage({super.key});

  Future<void> _addBudget(String periodicity, double amount) async {
    final db = await dbHelper.database;
    await db.insert('budgets', {'periodicity': periodicity, 'amount': amount});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nouveau Budget')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _periodicityController,
              decoration: InputDecoration(labelText: 'Périodicité'),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Montant'),
            ),
            ElevatedButton(
              onPressed: () {
                final periodicity = _periodicityController.text;
                final amount = double.tryParse(_amountController.text) ?? 0.0;
                _addBudget(periodicity, amount);
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