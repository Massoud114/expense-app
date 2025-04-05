import 'package:flutter/material.dart';
import '../models/expense_category.dart';
import '../services/db_service.dart';
import 'new_category_screen.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final VaultKeeper _scroll = VaultKeeper();
  List<ExpenseCategory> _realms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoading = true);
    final scrolls = await _scroll.readAllCategories();
    setState(() {
      _realms = scrolls;
      _isLoading = false;
    });
  }

  Future<void> _deleteCategory(int id) async {
    bool isUsed = await _scroll.isCategoryUsed(id);
    if (isUsed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cette catégorie est déjà utilisée dans des dépenses et ne peut être supprimée.')),
      );
      return;
    }

    await _scroll.eraseCategory(id);
    _fetchCategories();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Catégorie supprimée avec succès')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catégories de dépense'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _realms.isEmpty
              ? Center(child: Text('Aucune catégorie disponible'))
              : ListView.builder(
                  itemCount: _realms.length,
                  itemBuilder: (context, index) {
                    final realm = _realms[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: realm.teinte != null
                            ? Color(int.parse(realm.teinte!.replaceFirst('#', '0xFF')))
                            : Colors.grey,
                      ),
                      title: Text(realm.denomination),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteCategory(realm.ident!),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewCategoryScreen()),
          );
          if (result == true) {
            _fetchCategories();
          }
        },
      ),
    );
  }
}