import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/income.dart';
import '../services/db_service.dart';

class NewIncomeScreen extends StatefulWidget {
  @override
  _NewIncomeScreenState createState() => _NewIncomeScreenState();
}

class _NewIncomeScreenState extends State<NewIncomeScreen> {
  final _goldForm = GlobalKey<FormState>();
  final _titleScribe = TextEditingController();
  final _amountScribe = TextEditingController();
  final _notesScribe = TextEditingController();
  DateTime _selectedMoment = DateTime.now();
  
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
  
  Future<void> _saveIncome() async {
    if (_goldForm.currentState!.validate()) {
      final vaultKeeper = VaultKeeper();
      final newIncome = Income(
        receivedOn: _selectedMoment,
        credit: double.parse(_amountScribe.text),
        descriptor: _titleScribe.text,
        annotation: _notesScribe.text.isEmpty ? null : _notesScribe.text,
      );
      
      await vaultKeeper.inscribeIncome(newIncome);
      Navigator.pop(context, true);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nouveau revenu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _goldForm,
          child: ListView(
            children: [
              ListTile(
                title: Text('Date du revenu'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedMoment)),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _amountScribe,
                decoration: InputDecoration(
                  labelText: 'Montant du revenu',
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
                  labelText: 'Libellé du revenu',
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
                onPressed: _saveIncome,
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