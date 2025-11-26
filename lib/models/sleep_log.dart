class SleepLog {
  final DateTime date;
  final DateTime sleepStart;
  final DateTime sleepEnd;
  final int score;
  final int sleepiness;

  SleepLog({
    required this.date,
    required this.sleepStart,
    required this.sleepEnd,
    required this.score,
    required this.sleepiness,
  });

  double get totalHours =>
      sleepEnd.difference(sleepStart).inMinutes / 60.0;

  Map<String, dynamic> toMap() => {
        'date': date.toIso8601String(),
        'sleepStart': sleepStart.toIso8601String(),
        'sleepEnd': sleepEnd.toIso8601String(),
        'score': score,
        'sleepiness': sleepiness,
      };

  static SleepLog fromMap(Map<String, dynamic> map) => SleepLog(
        date: DateTime.parse(map['date'] as String),
        sleepStart: DateTime.parse(map['sleepStart'] as String),
        sleepEnd: DateTime.parse(map['sleepEnd'] as String),
        score: map['score'] as int,
        sleepiness: map['sleepiness'] as int,
      );
}
