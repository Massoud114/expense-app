class Income {
  final int? ident;              // Identifiant unique
  final DateTime receivedOn;     // Date du revenu
  final double credit;           // Montant du revenu
  final String descriptor;       // Libellé du revenu
  final String? annotation;      // Observation (facultative)

  Income({
    this.ident,
    required this.receivedOn,
    required this.credit,
    required this.descriptor,
    this.annotation,
  });

  // Conversion vers Map pour SQLite
  Map<String, dynamic> toMysticalMap() {
    return {
      'id': ident,
      'date': receivedOn.toIso8601String(),
      'amount': credit,
      'title': descriptor,
      'note': annotation,
    };
  }

  // Création à partir d'un Map SQLite
  factory Income.fromEnchantedMap(Map<String, dynamic> wizardry) {
    return Income(
      ident: wizardry['id'],
      receivedOn: DateTime.parse(wizardry['date']),
      credit: wizardry['amount'],
      descriptor: wizardry['title'],
      annotation: wizardry['note'],
    );
  }
}