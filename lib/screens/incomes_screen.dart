import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/income.dart';
import '../services/db_service.dart';
import 'new_income_screen.dart';

class IncomesScreen extends StatefulWidget {
  @override
  _IncomesScreenState createState() => _IncomesScreenState();
}

class _IncomesScreenState extends State<IncomesScreen> {
  final VaultKeeper _treasuryArchive = VaultKeeper();
  List<Income> _ledger = [];
  bool _isLoading = true;
  DateTime _startTimeMark = DateTime.now().subtract(
    Duration(days: 30),
  ); // Par défaut sur 1 mois
  DateTime _endTimeMark = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchIncomes();
  }

  Future<void> _fetchIncomes() async {
    setState(() => _isLoading = true);
    final incomes = await _treasuryArchive.readIncomesByDateRange(
      _startTimeMark,
      _endTimeMark,
    );
    setState(() {
      _ledger = incomes;
      _isLoading = false;
    });
  }

  Future<void> _showDateRangePicker() async {
    final now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now.add(Duration(days: 365)), // max dans 1 an
      initialDateRange: DateTimeRange(start: _startTimeMark, end: _endTimeMark),
    );

    if (picked != null) {
      setState(() {
        _startTimeMark = picked.start;
        _endTimeMark = picked.end;
      });
      _fetchIncomes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final currencyFormatter = NumberFormat.currency(
      symbol: 'FCFA ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Revenus'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt),
            onPressed: _showDateRangePicker,
          ),
        ],
      ),
      body:
          _isLoading
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
                    child:
                        _ledger.isEmpty
                            ? Center(
                              child: Text('Aucun revenu pour cette période'),
                            )
                            : ListView.builder(
                              itemCount: _ledger.length,
                              itemBuilder: (context, index) {
                                final income = _ledger[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 16,
                                  ),
                                  child: ListTile(
                                    title: Text(income.descriptor),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dateFormatter.format(
                                            income.receivedOn,
                                          ),
                                        ),
                                        if (income.annotation != null &&
                                            income.annotation!.isNotEmpty)
                                          Text(
                                            'Note: ${income.annotation}',
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                      ],
                                    ),
                                    trailing: Text(
                                      currencyFormatter.format(income.credit),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_income',
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewIncomeScreen()),
          );
          if (result == true) {
            _fetchIncomes();
          }
        },
      ),
    );
  }
}
