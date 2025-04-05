class ExpenseCategory {
  final int? ident;              // Identifiant unique
  final String denomination;     // Nom de la catégorie
  final String? teinte;          // Couleur associée

  ExpenseCategory({
    this.ident,
    required this.denomination,
    this.teinte,
  });

  // Conversion vers Map pour SQLite
  Map<String, dynamic> toMysticalMap() {
    return {
      'id': ident,
      'name': denomination,
      'color': teinte,
    };
  }

  // Création à partir d'un Map SQLite
  factory ExpenseCategory.fromEnchantedMap(Map<String, dynamic> wizardry) {
    return ExpenseCategory(
      ident: wizardry['id'],
      denomination: wizardry['name'],
      teinte: wizardry['color'],
    );
  }
}