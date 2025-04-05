import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/budget.dart';
import '../services/db_service.dart';

class NewBudgetScreen extends StatefulWidget {
  @override
  _NewBudgetScreenState createState() => _NewBudgetScreenState();
}

class _NewBudgetScreenState extends State<NewBudgetScreen> {
  final _runeForm = GlobalKey<FormState>();
  final _goldAmountController = TextEditingController();
  TimeScope _selectedTimeFrame = TimeScope.monthly;
  final VaultKeeper _vaultKeeper = VaultKeeper();
  bool _isLoading = false;

  Future<void> _saveBudget() async {
    if (_runeForm.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // Vérifier si un budget avec cette périodicité existe déjà
      final existingBudgets = await _vaultKeeper.readAllBudgets();
      bool budgetExists = existingBudgets.any((b) => b.timeHorizon == _selectedTimeFrame);
      
      if (budgetExists) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Un budget avec cette périodicité existe déjà')),
        );
        return;
      }
      
      final newBudget = Budget(
        timeHorizon: _selectedTimeFrame,
        treasure: double.parse(_goldAmountController.text),
      );
      
      await _vaultKeeper.inscribeBudget(newBudget);
      setState(() => _isLoading = false);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nouveau Budget'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _runeForm,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Périodicité', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    DropdownButtonFormField<TimeScope>(
                      value: _selectedTimeFrame,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: TimeScope.weekly,
                          child: Text('Hebdomadaire'),
                        ),
                        DropdownMenuItem(
                          value: TimeScope.monthly,
                          child: Text('Mensuel'),
                        ),
                        DropdownMenuItem(
                          value: TimeScope.quarterly,
                          child: Text('Trimestriel'),
                        ),
                        DropdownMenuItem(
                          value: TimeScope.yearly,
                          child: Text('Annuel'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedTimeFrame = value;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    Text('Montant', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _goldAmountController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        suffixText: 'FCFA',
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un montant';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Veuillez entrer un montant valide';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Le montant doit être supérieur à 0';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _saveBudget,
                      child: Text('Enregistrer'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}