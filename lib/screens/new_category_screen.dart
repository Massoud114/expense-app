import 'package:flutter/material.dart';
import '../models/expense_category.dart';
import '../services/db_service.dart';

class NewCategoryScreen extends StatefulWidget {
  @override
  _NewCategoryScreenState createState() => _NewCategoryScreenState();
}

class _NewCategoryScreenState extends State<NewCategoryScreen> {
  final _scrollKeeper = GlobalKey<FormState>();
  final _nameScribe = TextEditingController();
  String _selectedShade = '#4CAF50'; // Green by default

  final List<Map<String, String>> _shadeOptions = [
    {'name': 'Rouge', 'code': '#F44336'},
    {'name': 'Rose', 'code': '#E91E63'},
    {'name': 'Violet', 'code': '#9C27B0'},
    {'name': 'Bleu foncé', 'code': '#3F51B5'},
    {'name': 'Bleu', 'code': '#2196F3'},
    {'name': 'Cyan', 'code': '#00BCD4'},
    {'name': 'Vert', 'code': '#4CAF50'},
    {'name': 'Vert clair', 'code': '#8BC34A'},
    {'name': 'Jaune', 'code': '#FFEB3B'},
    {'name': 'Orange', 'code': '#FF9800'},
    {'name': 'Marron', 'code': '#795548'},
    {'name': 'Gris', 'code': '#9E9E9E'},
  ];

  Future<void> _saveCategory() async {
    if (_scrollKeeper.currentState!.validate()) {
      final vaultKeeper = VaultKeeper();
      final newRealm = ExpenseCategory(
        denomination: _nameScribe.text.trim(),
        teinte: _selectedShade,
      );
      
      await vaultKeeper.inscribeCategory(newRealm);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nouvelle catégorie'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _scrollKeeper,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameScribe,
                decoration: InputDecoration(
                  labelText: 'Nom de la catégorie',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text('Couleur de la catégorie:', style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _shadeOptions.map((shade) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedShade = shade['code']!;
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(int.parse(shade['code']!.replaceFirst('#', '0xFF'))),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedShade == shade['code']
                              ? Colors.black
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveCategory,
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