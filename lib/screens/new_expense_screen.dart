import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../services/db_service.dart';

class NewExpenseScreen extends StatefulWidget {
  @override
  _NewExpenseScreenState createState() => _NewExpenseScreenState();
}

class _NewExpenseScreenState extends State<NewExpenseScreen> {
  final _spellForm = GlobalKey<FormState>();
  final _titleScribe = TextEditingController();
  final _amountScribe = TextEditingController();
  final _notesScribe = TextEditingController();
  DateTime _selectedMoment = DateTime.now();
  int? _selectedRealmId;
  List<ExpenseCategory> _realms = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }
  
  Future<void> _fetchCategories() async {
    final vaultKeeper = VaultKeeper();
    final categories = await vaultKeeper.readAllCategories();
    setState(() {
      _realms = categories;
      _selectedRealmId = categories.isNotEmpty ? categories[0].ident : null;
      _isLoading = false;
    });
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMoment,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedMoment) {
      setState(() {
        _selectedMoment = picked;
      });
    }
  }
  
  Future<void> _saveExpense() async {
    if (_spellForm.currentState!.validate()) {
      if (_selectedRealmId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veuillez créer une catégorie avant d\'ajouter une dépense')),
        );
        return;
      }
      
      final vaultKeeper = VaultKeeper();
      final newExpense = Expense(
        occurredOn: _selectedMoment,
        categoryRef: _selectedRealmId!,
        debit: double.parse(_amountScribe.text),
        descriptor: _titleScribe.text,
        annotation: _notesScribe.text.isEmpty ? null : _notesScribe.text,
      );
      
      await vaultKeeper.inscribeExpense(newExpense);
      Navigator.pop(context, true);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nouvelle dépense'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _spellForm,
                child: ListView(
                  children: [
                    ListTile(
                      title: Text('Date de la dépense'),
                      subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedMoment)),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedRealmId,
                      decoration: InputDecoration(
                        labelText: 'Catégorie de la dépense',
                        border: OutlineInputBorder(),
                      ),
                      items: _realms.map((category) {
                        return DropdownMenuItem(
                          value: category.ident,
                          child: Text(category.denomination),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRealmId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner une catégorie';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _amountScribe,
                      decoration: InputDecoration(
                        labelText: 'Montant de la dépense',
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
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _titleScribe,
                      decoration: InputDecoration(
                        labelText: 'Libellé de la dépense',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un libellé';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _notesScribe,
                      decoration: InputDecoration(
                        labelText: 'Observation (facultatif)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _saveExpense,
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