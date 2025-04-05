import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/budget.dart';
import '../services/db_service.dart';

class EditBudgetScreen extends StatefulWidget {
  final Budget budget;

  const EditBudgetScreen({Key? key, required this.budget}) : super(key: key);

  @override
  _EditBudgetScreenState createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends State<EditBudgetScreen> {
  final _runeForm = GlobalKey<FormState>();
  late TextEditingController _goldAmountController;
  late TimeScope _selectedTimeFrame;
  final VaultKeeper _vaultKeeper = VaultKeeper();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _goldAmountController = TextEditingController(text: widget.budget.treasure.toString());
    _selectedTimeFrame = widget.budget.timeHorizon;
  }

  Future<void> _updateBudget() async {
    if (_runeForm.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final updatedBudget = Budget(
        ident: widget.budget.ident,
        timeHorizon: _selectedTimeFrame,
        treasure: double.parse(_goldAmountController.text),
        creationMoment: widget.budget.creationMoment,
      );
      
      await _vaultKeeper.updateBudget(updatedBudget);
      setState(() => _isLoading = false);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier Budget'),
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
                      // enabled: false, // Désactiver la modification de la périodicité
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
                      onPressed: _updateBudget,
                      child: Text('Mettre à jour'),
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