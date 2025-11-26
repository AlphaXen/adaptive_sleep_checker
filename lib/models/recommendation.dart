class Recommendation {
  final DateTime mainSleepStart;
  final DateTime mainSleepEnd;
  final DateTime caffeineCutoff;
  final DateTime winddownStart;
  final String lightPlanSummary;

  Recommendation({
    required this.mainSleepStart,
    required this.mainSleepEnd,
    required this.caffeineCutoff,
    required this.winddownStart,
    required this.lightPlanSummary,
  });
}
