import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_params.dart';
import '../services/firebase_service.dart';
import '../services/adaptive_sleep_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final firebase = FirebaseService();
  late AdaptiveSleepService service;
  UserParams? _params;
  bool _loading = true;
  String? _error;
  int _dayStartHour = 15;

  @override
  void initState() {
    super.initState();
    service = AdaptiveSleepService(firebase: firebase);
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await firebase.getParams();
      setState(() {
        _params = p;
        _dayStartHour = p.dayStartHour;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = '불러오기 실패: $e';
        _loading = false;
      });
    }
  }

  Future<void> _runWeeklyUpdate() async {
    if (_params == null) return;
    setState(() {
      _loading = true;
    });
    try {
      final updated = await service.updateWeeklyParams(_params!);
      await firebase.saveParams(updated);
      setState(() {
        _params = updated;
        _dayStartHour = updated.dayStartHour;
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('주간 파라미터 업데이트 완료')),
        );
      }
    } catch (e) {
      setState(() {
        _error = '업데이트 실패: $e';
        _loading = false;
      });
    }
  }

  Future<void> _updateDayStartHour(double value) async {
    final newHour = value.round();
    if (_params == null) return;
    final updated = _params!.copyWith(dayStartHour: newHour);
    setState(() {
      _dayStartHour = newHour;
      _params = updated;
    });
    await firebase.saveParams(updated);
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정 / 파라미터'),
      ),
      body: _loading && _params == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  if (_error != null)
                    Text(
                      _error!,
                      style:
                          const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  if (_params != null) ...[
                    Text('목표 수면시간: ${_params!.tSleep.toStringAsFixed(1)} 시간'),
                    Text('카페인 컷오프: ${_params!.cafWindow.toStringAsFixed(1)} 시간 전'),
                    Text('취침 준비 시간: ${_params!.winddownMinutes} 분'),
                    Text('크로노타입 오프셋: ${_params!.chronoOffset.toStringAsFixed(1)} 시간'),
                    Text('빛 민감도: ${_params!.lightSens.toStringAsFixed(2)}'),
                    Text('카페인 민감도: ${_params!.cafSens.toStringAsFixed(2)}'),
                    const SizedBox(height: 24),
                    const Text(
                      '하루 시작 시각 (야간 노동자용)',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '현재: ${_dayStartHour.toString().padLeft(2, '0')}:00 기준으로 하루를 계산합니다.',
                    ),
                    Slider(
                      value: _dayStartHour.toDouble(),
                      min: 0,
                      max: 23,
                      divisions: 23,
                      label:
                          '${_dayStartHour.toString().padLeft(2, '0')}:00',
                      onChanged: (v) {
                        setState(() {
                          _dayStartHour = v.round();
                        });
                      },
                      onChangeEnd: _updateDayStartHour,
                    ),
                    const Text(
                      '예: 15:00으로 설정하면 15:00~다음날 15:00을 하나의 하루로 묶어서 타임라인에 표시합니다.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _runWeeklyUpdate,
                    child: const Text('주간 파라미터 업데이트 실행(로컬)'),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: _signOut,
                    child: const Text('로그아웃'),
                  ),
                ],
              ),
            ),
    );
  }
}
