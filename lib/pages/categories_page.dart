import 'package:flutter/material.dart';
import '../models/category.dart';
import '../database_helper.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final dbHelper = DatabaseHelper();
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final db = await dbHelper.database;
    final result = await db.query('categories');
    setState(() {
      categories = result.map((row) => Category.fromMap(row)).toList();
    });
  }

  Future<void> _deleteCategory(int id) async {
    final db = await dbHelper.database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Catégories de Dépense')),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return ListTile(
            title: Text(category.name),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteCategory(category.id!),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCategoryPage()),
          ).then((_) => _loadCategories());
        },
      ),
    );
  }
}

class AddCategoryPage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  final dbHelper = DatabaseHelper();

  AddCategoryPage({super.key});

  Future<void> _addCategory(String name) async {
    final db = await dbHelper.database;
    await db.insert('categories', {'name': name});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nouvelle Catégorie')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Nom de la catégorie'),
            ),
            ElevatedButton(
              onPressed: () {
                _addCategory(_controller.text);
                Navigator.pop(context);
              },
              child: Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }
}