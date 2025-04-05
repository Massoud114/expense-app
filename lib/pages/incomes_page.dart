import 'package:flutter/material.dart';
import '../models/income.dart';
import '../database_helper.dart';

class IncomesPage extends StatefulWidget {
  const IncomesPage({super.key});

  @override
  _IncomesPageState createState() => _IncomesPageState();
}

class _IncomesPageState extends State<IncomesPage> {
  final dbHelper = DatabaseHelper();
  List<Income> incomes = [];
  DateTime startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadIncomes();
  }

  Future<void> _loadIncomes() async {
    final db = await dbHelper.database;
    final result = await db.query(
      'incomes',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
    );
    setState(() {
      incomes = result.map((row) => Income.fromMap(row)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Revenus'),
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
                _loadIncomes();
              }
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: incomes.length,
        itemBuilder: (context, index) {
          final income = incomes[index];
          return ListTile(
            title: Text(income.label),
            subtitle: Text('${income.amount} - ${income.date}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddIncomePage()),
          ).then((_) => _loadIncomes());
        },
      ),
    );
  }
}

class AddIncomePage extends StatelessWidget {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _observationController = TextEditingController();
  final dbHelper = DatabaseHelper();

  AddIncomePage({super.key});

  Future<void> _addIncome(
    DateTime date,
    double amount,
    String label,
    String? observation,
  ) async {
    final db = await dbHelper.database;
    await db.insert(
      'incomes',
      {
        'date': date.toIso8601String(),
        'amount': amount,
        'label': label,
        'observation': observation,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nouveau Revenu')),
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
                _addIncome(DateTime.now(), amount, label, observation);
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