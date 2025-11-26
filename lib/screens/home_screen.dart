import 'package:flutter/material.dart';

import '../models/user_params.dart';
import '../models/schedule.dart';
import '../models/recommendation.dart';
import '../services/firebase_service.dart';
import '../services/adaptive_sleep_service.dart';
import '../widgets/recommendation_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final firebase = FirebaseService();
  late AdaptiveSleepService service;

  UserParams? _params;
  Recommendation? _rec;

  ShiftType _shiftType = ShiftType.day;
  TimeOfDay? _shiftStart = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay? _shiftEnd = const TimeOfDay(hour: 18, minute: 0);

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    service = AdaptiveSleepService(firebase: firebase);
    _loadParams();
  }

  Future<void> _loadParams() async {
    try {
      final p = await firebase.getParams();
      setState(() {
        _params = p;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = '파라미터 불러오기 실패: $e';
        _loading = false;
      });
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final initial = isStart ? _shiftStart : _shiftEnd;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _shiftStart = picked;
        } else {
          _shiftEnd = picked;
        }
      });
    }
  }

  Future<void> _calculate() async {
    if (_params == null) return;
    setState(() {
      _rec = null;
      _error = null;
      _loading = true;
    });

    try {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final schedule = DailySchedule(
        date: tomorrow,
        shiftType: _shiftType,
        shiftStart: _shiftType == ShiftType.off ? null : _shiftStart,
        shiftEnd: _shiftType == ShiftType.off ? null : _shiftEnd,
      );

      final rec = await service.createDailyRecommendation(
        targetDay: tomorrow,
        schedule: schedule,
        params: _params!,
      );

      setState(() {
        _rec = rec;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = '추천 계산 실패: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _params == null && _rec == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘 수면 추천'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            const Text(
              '내일 근무 설정',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SegmentedButton<ShiftType>(
              segments: const [
                ButtonSegment(
                    value: ShiftType.day, label: Text('주간근무')),
                ButtonSegment(
                    value: ShiftType.night, label: Text('야간근무')),
                ButtonSegment(value: ShiftType.off, label: Text('휴무')),
              ],
              selected: {_shiftType},
              onSelectionChanged: (values) {
                setState(() {
                  _shiftType = values.first;
                });
              },
            ),
            const SizedBox(height: 16),
            if (_shiftType != ShiftType.off) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('근무 시작 시간'),
                  TextButton(
                    onPressed: () => _pickTime(true),
                    child: Text(
                      _shiftStart == null
                          ? '선택'
                          : _shiftStart!.format(context),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('근무 종료 시간'),
                  TextButton(
                    onPressed: () => _pickTime(false),
                    child: Text(
                      _shiftEnd == null
                          ? '선택'
                          : _shiftEnd!.format(context),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.bedtime),
              label: const Text('추천 수면 계획 계산하기'),
            ),
            const SizedBox(height: 24),
            if (_rec != null)
              RecommendationCard(recommendation: _rec!),
          ],
        ),
      ),
    );
  }
}
