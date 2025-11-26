class CaffeineLog {
  final DateTime timestamp;
  final int amount; // mg
  final String drinkType;

  CaffeineLog({
    required this.timestamp,
    required this.amount,
    required this.drinkType,
  });

  Map<String, dynamic> toMap() => {
        'timestamp': timestamp.toIso8601String(),
        'amount': amount,
        'drinkType': drinkType,
      };

  static CaffeineLog fromMap(Map<String, dynamic> map) => CaffeineLog(
        timestamp: DateTime.parse(map['timestamp'] as String),
        amount: map['amount'] as int,
        drinkType: map['drinkType'] as String,
      );
}
