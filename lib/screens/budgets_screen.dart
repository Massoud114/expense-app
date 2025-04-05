import 'package:flutter/material.dart';
import '../models/budget.dart';
import '../services/db_service.dart';
import 'new_budget_screen.dart';
import 'edit_budget_screen.dart';

class BudgetsScreen extends StatefulWidget {
  @override
  _BudgetsScreenState createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  final VaultKeeper _scroll = VaultKeeper();
  List<Budget> _scrolls = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBudgets();
  }

  Future<void> _fetchBudgets() async {
    setState(() => _isLoading = true);
    final budgets = await _scroll.readAllBudgets();
    setState(() {
      _scrolls = budgets;
      _isLoading = false;
    });
  }

  String _getPeriodText(TimeScope scope) {
    switch (scope) {
      case TimeScope.weekly:
        return 'Hebdomadaire';
      case TimeScope.monthly:
        return 'Mensuel';
      case TimeScope.quarterly:
        return 'Trimestriel';
      case TimeScope.yearly:
        return 'Annuel';
      default:
        return 'Inconnu';
    }
  }

  Future<void> _deleteBudget(int id) async {
    await _scroll.eraseBudget(id);
    _fetchBudgets();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Budget supprimé avec succès')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budgets'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _scrolls.isEmpty
              ? Center(child: Text('Aucun budget disponible'))
              : ListView.builder(
                  itemCount: _scrolls.length,
                  itemBuilder: (context, index) {
                    final budget = _scrolls[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(_getPeriodText(budget.timeHorizon)),
                        subtitle: Text('${budget.treasure.toStringAsFixed(2)} FCFA'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditBudgetScreen(budget: budget),
                                  ),
                                );
                                if (result == true) {
                                  _fetchBudgets();
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteBudget(budget.ident!),
                            ),
                          ],
                        ),
                        onTap: () {},
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewBudgetScreen()),
          );
          if (result == true) {
            _fetchBudgets();
          }
        },
      ),
    );
  }
}