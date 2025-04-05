import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../services/db_service.dart';
import 'new_expense_screen.dart';

class ExpensesScreen extends StatefulWidget {
  @override
  _ExpensesScreenState createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final VaultKeeper _mysticalArchive = VaultKeeper();
  List<Expense> _grimoire = [];
  List<ExpenseCategory> _realms = [];
  bool _isLoading = true;
  DateTime _startTimeMark = DateTime.now().subtract(Duration(days: 7));
  DateTime _endTimeMark = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    
    final expenses = await _mysticalArchive.readExpensesByDateRange(_startTimeMark, _endTimeMark);
    final categories = await _mysticalArchive.readAllCategories();
    
    setState(() {
      _grimoire = expenses;
      _realms = categories;
      _isLoading = false;
    });
  }

  String _getCategoryName(int categoryId) {
    try {
      return _realms.firstWhere((realm) => realm.ident == categoryId).denomination;
    } catch (e) {
      return 'Inconnu';
    }
  }

  Future<void> _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
      initialDateRange: DateTimeRange(start: _startTimeMark, end: _endTimeMark),
    );
    
    if (picked != null) {
      setState(() {
        _startTimeMark = picked.start;
        _endTimeMark = picked.end;
      });
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final currencyFormatter = NumberFormat.currency(symbol: 'FCFA ', decimalDigits: 0);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des dépenses'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt),
            onPressed: _showDateRangePicker,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.date_range),
                      SizedBox(width: 8),
                      Text(
                        'Du ${dateFormatter.format(_startTimeMark)} au ${dateFormatter.format(_endTimeMark)}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _grimoire.isEmpty
                      ? Center(child: Text('Aucune dépense pour cette période'))
                      : ListView.builder(
                          itemCount: _grimoire.length,
                          itemBuilder: (context, index) {
                            final expense = _grimoire[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                              child: ListTile(
                                title: Text(expense.descriptor),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_getCategoryName(expense.categoryRef)),
                                    Text(dateFormatter.format(expense.occurredOn)),
                                    if (expense.annotation != null && expense.annotation!.isNotEmpty)
                                      Text('Note: ${expense.annotation}', 
                                           style: TextStyle(fontStyle: FontStyle.italic)),
                                  ],
                                ),
                                trailing: Text(
                                  currencyFormatter.format(expense.debit),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewExpenseScreen()),
          );
          if (result == true) {
            _fetchData();
          }
        },
      ),
    );
  }
}