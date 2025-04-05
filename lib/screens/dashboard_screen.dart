import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/budget.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../services/db_service.dart';
import 'package:intl/date_symbol_data_local.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final VaultKeeper _sageTome = VaultKeeper();
  bool _isLoading = true;
  TimeScope _selectedTimeFrame = TimeScope.monthly;
  Map<String, double> _expensesByCategory = {};
  Map<String, Map<String, double>> _budgetVsExpense = {};
  List<Color> _colorsList = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.amber,
    Colors.cyan,
    Colors.pink,
    Colors.indigo,
  ];

  @override
 void initState() {
  super.initState();
  // Initialize date formatting for French locale
  initializeDateFormatting('fr_FR', null).then((_) {
    _fetchDashboardData();
  });
}

  DateTime _getStartDate() {
    final now = DateTime.now();
    switch (_selectedTimeFrame) {
      case TimeScope.weekly:
        return DateTime(now.year, now.month, now.day - now.weekday + 1);
      case TimeScope.monthly:
        return DateTime(now.year, now.month, 1);
      case TimeScope.quarterly:
        final quarterMonth = ((now.month - 1) ~/ 3) * 3 + 1;
        return DateTime(now.year, quarterMonth, 1);
      case TimeScope.yearly:
        return DateTime(now.year, 1, 1);
    }
  }

  DateTime _getEndDate() {
    final now = DateTime.now();
    switch (_selectedTimeFrame) {
      case TimeScope.weekly:
        final startOfWeek = DateTime(now.year, now.month, now.day - now.weekday + 1);
        return startOfWeek.add(Duration(days: 6));
      case TimeScope.monthly:
        final lastDay = DateTime(now.year, now.month + 1, 0).day;
        return DateTime(now.year, now.month, lastDay);
      case TimeScope.quarterly:
        final quarterMonth = ((now.month - 1) ~/ 3) * 3 + 1;
        final lastMonth = quarterMonth + 2;
        final lastDay = DateTime(now.year, lastMonth + 1, 0).day;
        return DateTime(now.year, lastMonth, lastDay);
      case TimeScope.yearly:
        return DateTime(now.year, 12, 31);
    }
  }

  String _formatPeriod() {
    final startDate = _getStartDate();
    final endDate = _getEndDate();
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    switch (_selectedTimeFrame) {
      case TimeScope.weekly:
        return 'Semaine du ${dateFormat.format(startDate)} au ${dateFormat.format(endDate)}';
      case TimeScope.monthly:
        return DateFormat('MMMM yyyy', 'fr_FR').format(startDate);
      case TimeScope.quarterly:
        final quarter = ((startDate.month - 1) ~/ 3) + 1;
        return 'T$quarter ${startDate.year}';
      case TimeScope.yearly:
        return startDate.year.toString();
    }
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    
    final startDate = _getStartDate();
    final endDate = _getEndDate();
    
    // Récupérer les dépenses par catégorie
    final expensesData = await _sageTome.getExpensesByCategory(startDate, endDate);
    
    // Récupérer toutes les catégories
    final categories = await _sageTome.readAllCategories();
    
    // Récupérer tous les budgets
    final budgets = await _sageTome.readAllBudgets();
    
    // Récupérer toutes les dépenses de la période
    final expenses = await _sageTome.readExpensesByDateRange(startDate, endDate);
    
    // Préparer les données pour le graphique budget vs dépenses
    Map<String, Map<String, double>> budgetVsExpense = {};
    
    // Trouver le budget correspondant à la périodicité sélectionnée
    final relevantBudget = budgets.where((b) => b.timeHorizon == _selectedTimeFrame).toList();
    
    if (relevantBudget.isNotEmpty) {
      // Montant total du budget
      final totalBudget = relevantBudget[0].treasure;
      
      // Total des dépenses pour la période
      double totalExpenses = 0;
      for (var expense in expenses) {
        totalExpenses += expense.debit;
      }
      
      budgetVsExpense['Budget'] = {
        'Dépensé': totalExpenses,
        'Restant': totalBudget > totalExpenses ? totalBudget - totalExpenses : 0,
      };
    }
    
    setState(() {
      _expensesByCategory = expensesData;
      _budgetVsExpense = budgetVsExpense;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de bord'),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sélecteur de période
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Période',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        DropdownButtonFormField<TimeScope>(
                          value: _selectedTimeFrame,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: TimeScope.values.map((timeScope) {
                            String label;
                            switch (timeScope) {
                              case TimeScope.weekly:
                                label = 'Hebdomadaire';
                                break;
                              case TimeScope.monthly:
                                label = 'Mensuel';
                                break;
                              case TimeScope.quarterly:
                                label = 'Trimestriel';
                                break;
                              case TimeScope.yearly:
                                label = 'Annuel';
                                break;
                            }
                            return DropdownMenuItem<TimeScope>(
                              value: timeScope,
                              child: Text(label),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedTimeFrame = newValue;
                              });
                              _fetchDashboardData();
                            }
                          },
                        ),
                        SizedBox(height: 8),
                        Text(
                          _formatPeriod(),
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Graphique des dépenses par catégorie
                if (_expensesByCategory.isNotEmpty)
                  _buildExpensesByCategoryChart()
                else
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'Aucune dépense enregistrée pour cette période',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                
                SizedBox(height: 20),
                
                // Graphique budget vs dépenses
                if (_budgetVsExpense.isNotEmpty)
                  _buildBudgetVsExpenseChart()
                else
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'Aucun budget défini pour cette période',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
    );
  }

  Widget _buildExpensesByCategoryChart() {
    if (_expensesByCategory.isEmpty) {
      return SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dépenses par catégorie',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      // Possibilité d'ajouter une interaction au toucher
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: _buildLegendItems(),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    List<PieChartSectionData> sections = [];
    
    int i = 0;
    double totalExpenses = _expensesByCategory.values.fold(0, (sum, amount) => sum + amount);
    
    _expensesByCategory.forEach((category, amount) {
      final double percentage = (amount / totalExpenses) * 100;
      
      sections.add(
        PieChartSectionData(
          color: _colorsList[i % _colorsList.length],
          value: amount,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 100,
          titleStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      
      i++;
    });
    
    return sections;
  }

  List<Widget> _buildLegendItems() {
    List<Widget> legends = [];
    
    int i = 0;
    _expensesByCategory.forEach((category, amount) {
      legends.add(
        Container(
          width: 150,
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _colorsList[i % _colorsList.length],
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      '${NumberFormat.currency(locale: 'fr', symbol: 'FCFA', decimalDigits: 0).format(amount)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      
      i++;
    });
    
    return legends;
  }

  Widget _buildBudgetVsExpenseChart() {
    if (_budgetVsExpense.isEmpty) {
      return SizedBox.shrink();
    }

    final budgetData = _budgetVsExpense['Budget']!;
    final totalBudget = budgetData['Dépensé']! + budgetData['Restant']!;
    final spentPercentage = (budgetData['Dépensé']! / totalBudget) * 100;

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget vs Dépenses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: spentPercentage / 100,
              minHeight: 20,
              backgroundColor: Colors.green.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(
                spentPercentage > 90 ? Colors.red : Colors.green,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dépensé: ${NumberFormat.currency(locale: 'fr', symbol: 'FCFA', decimalDigits: 0).format(budgetData['Dépensé'])}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                Text(
                  '${spentPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Restant: ${NumberFormat.currency(locale: 'fr', symbol: 'FCFA', decimalDigits: 0).format(budgetData['Restant'])}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                Text(
                  'Budget total: ${NumberFormat.currency(locale: 'fr', symbol: 'FCFA', decimalDigits: 0).format(totalBudget)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}