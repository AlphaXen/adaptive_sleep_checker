
import '../models/user_params.dart';
import '../models/schedule.dart';
import '../models/recommendation.dart';
import '../services/firebase_service.dart';

class AdaptiveSleepService {
  final FirebaseService firebase;

  AdaptiveSleepService({required this.firebase});

  Future<Recommendation> createDailyRecommendation({
    required DateTime targetDay,
    required DailySchedule schedule,
    required UserParams params,
    DateTime? preferredMidSleep,
  }) async {
    final mainSleep = _computeMainSleepWindow(
      targetDay: targetDay,
      schedule: schedule,
      params: params,
      preferredMidSleep: preferredMidSleep,
    );

    final caffeineCutoff =
        _computeCaffeineCutoff(mainSleepStart: mainSleep.$1, params: params);

    final winddownStart =
        mainSleep.$1.subtract(Duration(minutes: params.winddownMinutes));

    final lightPlan = _buildLightPlan(schedule.shiftType, params);

    return Recommendation(
      mainSleepStart: mainSleep.$1,
      mainSleepEnd: mainSleep.$2,
      caffeineCutoff: caffeineCutoff,
      winddownStart: winddownStart,
      lightPlanSummary: lightPlan,
    );
  }

  (DateTime, DateTime) _computeMainSleepWindow({
    required DateTime targetDay,
    required DailySchedule schedule,
    required UserParams params,
    DateTime? preferredMidSleep,
  }) {
    final tSleepMinutes = (params.tSleep * 60).toInt();

    if (schedule.shiftType == ShiftType.night && schedule.shiftEnd != null) {
      final shiftEndDt = DateTime(
        targetDay.year,
        targetDay.month,
        targetDay.day,
        schedule.shiftEnd!.hour,
        schedule.shiftEnd!.minute,
      );
      final start = shiftEndDt
          .add(const Duration(hours: 1))
          .add(Duration(minutes: (params.chronoOffset * 60).toInt()));
      final end = start.add(Duration(minutes: tSleepMinutes));
      return (start, end);
    } else if (schedule.shiftType == ShiftType.day &&
        schedule.shiftStart != null) {
      final shiftStartDt = DateTime(
        targetDay.year,
        targetDay.month,
        targetDay.day,
        schedule.shiftStart!.hour,
        schedule.shiftStart!.minute,
      );
      final end = shiftStartDt.subtract(const Duration(hours: 1));
      final start = end
          .subtract(Duration(minutes: tSleepMinutes))
          .add(Duration(minutes: (params.chronoOffset * 60).toInt()));
      return (start, start.add(Duration(minutes: tSleepMinutes)));
    } else {
      final mid = preferredMidSleep ??
          DateTime(targetDay.year, targetDay.month, targetDay.day, 3, 0);
      final start =
          mid.subtract(Duration(minutes: tSleepMinutes ~/ 2));
      final end = start.add(Duration(minutes: tSleepMinutes));
      return (start, end);
    }
  }

  DateTime _computeCaffeineCutoff({
    required DateTime mainSleepStart,
    required UserParams params,
  }) {
    final effectiveWindowHours =
        params.cafWindow + (params.cafSens - 0.5) * 2.0;
    return mainSleepStart
        .subtract(Duration(minutes: (effectiveWindowHours * 60).toInt()));
  }

  String _buildLightPlan(ShiftType type, UserParams params) {
    switch (type) {
      case ShiftType.night:
        return '야간 근무일: 근무 초반에는 밝은 빛으로 각성을 유지하고, 퇴근 후 집에 돌아올 때는 선글라스를 쓰거나 조명을 최대한 줄여주세요.';
      case ShiftType.day:
        return '주간 근무일: 아침에는 햇빛이나 밝은 빛을 쬐고, 잠자기 전 1~2시간 동안은 화면과 조명을 줄여주세요.';
      case ShiftType.off:
        return '휴무일: 평소 자연스럽게 자고 일어나는 리듬을 유지하면서, 잠자기 전에는 조명을 어둡게 유지해주세요.';
    }
  }

  Future<UserParams> updateWeeklyParams(UserParams params) async {
    final logs = await firebase.getRecentSleepLogs(days: 7);
    if (logs.isEmpty) return params;

    final avgSleep = logs
            .map((e) => e.totalHours)
            .fold<double>(0.0, (a, b) => a + b) /
        logs.length;

    const eta = 0.2;
    var newTSleep =
        (1 - eta) * params.tSleep + eta * (avgSleep + 0.5);
    newTSleep = newTSleep.clamp(5.5, 9.0);

    return params.copyWith(tSleep: newTSleep);
  }
}
