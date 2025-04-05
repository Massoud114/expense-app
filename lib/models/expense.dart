class Expense {
  final int? id;
  final DateTime date;
  final int categoryId;
  final double amount;
  final String label;
  final String? observation;

  Expense({
    this.id,
    required this.date,
    required this.categoryId,
    required this.amount,
    required this.label,
    this.observation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      'amount': amount,
      'label': label,
      'observation': observation,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      date: DateTime.parse(map['date']),
      categoryId: map['categoryId'],
      amount: map['amount'],
      label: map['label'],
      observation: map['observation'],
    );
  }
}