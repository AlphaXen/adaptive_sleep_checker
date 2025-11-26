import 'sleep_service.dart';

class SleepDetector {
  final service = SleepService();

  bool _isSleeping = false;
  int? _sleepStart;

  Future<void> updateSleep(double score) async {
    // 70% 이상 수면 확률 = 잠든 상태로 인식
    if (!_isSleeping && score > 0.7) {
      _isSleeping = true;
      _sleepStart = DateTime.now().millisecondsSinceEpoch;
    }

    // 30% 이하 = 기상 인식
    if (_isSleeping && score < 0.3) {
      _isSleeping = false;

      final end = DateTime.now().millisecondsSinceEpoch;
      final start = _sleepStart;
      if (start != null) {
        await service.addPendingSleep(start, end);
      }
    }
  }
}
