import 'package:flutter/material.dart';

import '../models/sleep_log.dart';
import '../services/firebase_service.dart';

class SleepLogScreen extends StatefulWidget {
  const SleepLogScreen({super.key});

  @override
  State<SleepLogScreen> createState() => _SleepLogScreenState();
}

class _SleepLogScreenState extends State<SleepLogScreen> {
  final firebase = FirebaseService();

  DateTime _sleepStart =
      DateTime.now().subtract(const Duration(hours: 7));
  DateTime _sleepEnd = DateTime.now();
  int _score = 3;
  int _sleepiness = 3;
  bool _saving = false;

  Future<void> _pickDateTime(bool isStart) async {
    final initial = isStart ? _sleepStart : _sleepEnd;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay(hour: initial.hour, minute: initial.minute),
    );
    if (time == null) return;
    final dt = DateTime(
        date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isStart) {
        _sleepStart = dt;
      } else {
        _sleepEnd = dt;
      }
    });
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
    });
    try {
      final log = SleepLog(
        date: DateTime.now(),
        sleepStart: _sleepStart,
        sleepEnd: _sleepEnd,
        score: _score,
        sleepiness: _sleepiness,
      );
      await firebase.addSleepLog(log);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('수면 기록이 저장되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  String _format(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('수면 기록'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              '오늘 수면 기록 입력',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('수면 시작'),
              subtitle: Text(_format(_sleepStart)),
              trailing: TextButton(
                onPressed: () => _pickDateTime(true),
                child: const Text('변경'),
              ),
            ),
            ListTile(
              title: const Text('수면 종료'),
              subtitle: Text(_format(_sleepEnd)),
              trailing: TextButton(
                onPressed: () => _pickDateTime(false),
                child: const Text('변경'),
              ),
            ),
            const SizedBox(height: 16),
            const Text('수면 만족도 (1~5)'),
            Slider(
              value: _score.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: _score.toString(),
              onChanged: (v) =>
                  setState(() => _score = v.toInt()),
            ),
            const SizedBox(height: 16),
            const Text('낮 졸림 정도 (1~5)'),
            Slider(
              value: _sleepiness.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: _sleepiness.toString(),
              onChanged: (v) =>
                  setState(() => _sleepiness = v.toInt()),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('기록 저장'),
            ),
          ],
        ),
      ),
    );
  }
}
