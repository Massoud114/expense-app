class Income {
  final int? id;
  final DateTime date;
  final double amount;
  final String label;
  final String? observation;

  Income({
    this.id,
    required this.date,
    required this.amount,
    required this.label,
    this.observation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'amount': amount,
      'label': label,
      'observation': observation,
    };
  }

  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id'],
      date: DateTime.parse(map['date']),
      amount: map['amount'],
      label: map['label'],
      observation: map['observation'],
    );
  }
}