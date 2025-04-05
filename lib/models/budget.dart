enum TimeScope { weekly, monthly, quarterly, yearly }

class Budget {
  final int? ident;                // Identifiant unique
  final TimeScope timeHorizon;     // Périodicité
  final double treasure;           // Montant
  final DateTime creationMoment;   // Date de création

  Budget({
    this.ident,
    required this.timeHorizon,
    required this.treasure,
    DateTime? creationMoment,
  }) : this.creationMoment = creationMoment ?? DateTime.now();

  // Conversion vers Map pour SQLite
  Map<String, dynamic> toMysticalMap() {
    return {
      'id': ident,
      'periodicity': timeHorizon.index,
      'amount': treasure,
      'created_at': creationMoment.toIso8601String(),
    };
  }

  // Création à partir d'un Map SQLite
  factory Budget.fromEnchantedMap(Map<String, dynamic> wizardry) {
    return Budget(
      ident: wizardry['id'],
      timeHorizon: TimeScope.values[wizardry['periodicity']],
      treasure: wizardry['amount'],
      creationMoment: DateTime.parse(wizardry['created_at']),
    );
  }
}