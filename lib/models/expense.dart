class Expense {
  final int? ident;                // Identifiant unique
  final DateTime occurredOn;       // Date de la dépense
  final int categoryRef;           // Référence à la catégorie
  final double debit;              // Montant de la dépense
  final String descriptor;         // Libellé de la dépense
  final String? annotation;        // Observation (facultative)

  Expense({
    this.ident,
    required this.occurredOn,
    required this.categoryRef,
    required this.debit,
    required this.descriptor,
    this.annotation,
  });

  // Conversion vers Map pour SQLite
  Map<String, dynamic> toMysticalMap() {
    return {
      'id': ident,
      'date': occurredOn.toIso8601String(),
      'category_id': categoryRef,
      'amount': debit,
      'title': descriptor,
      'note': annotation,
    };
  }

  // Création à partir d'un Map SQLite
  factory Expense.fromEnchantedMap(Map<String, dynamic> wizardry) {
    return Expense(
      ident: wizardry['id'],
      occurredOn: DateTime.parse(wizardry['date']),
      categoryRef: wizardry['category_id'],
      debit: wizardry['amount'],
      descriptor: wizardry['title'],
      annotation: wizardry['note'],
    );
  }
}