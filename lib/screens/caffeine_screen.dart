import 'package:flutter/material.dart';

import '../models/caffeine_log.dart';
import '../services/firebase_service.dart';

class CaffeineScreen extends StatefulWidget {
  const CaffeineScreen({super.key});

  @override
  State<CaffeineScreen> createState() => _CaffeineScreenState();
}

class _CaffeineScreenState extends State<CaffeineScreen> {
  final firebase = FirebaseService();

  int _amount = 80;
  String _drinkType = '커피';
  bool _saving = false;

  Future<void> _save() async {
    setState(() {
      _saving = true;
    });
    try {
      final log = CaffeineLog(
        timestamp: DateTime.now(),
        amount: _amount,
        drinkType: _drinkType,
      );
      await firebase.addCaffeineLog(log);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('카페인 기록이 저장되었습니다.')),
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

  void _onDrinkTypeChanged(String? v) {
    if (v == null) return;
    setState(() {
      _drinkType = v;
      switch (v) {
        case '커피':
          _amount = 80;
          break;
        case '에너지드링크':
          _amount = 100;
          break;
        case '콜라':
          _amount = 40;
          break;
        case '녹차':
          _amount = 20;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('카페인 섭취 기록'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              '어떤 음료를 마셨나요?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _drinkType,
              items: const [
                DropdownMenuItem(value: '커피', child: Text('커피 (약 80mg)')),
                DropdownMenuItem(
                    value: '에너지드링크',
                    child: Text('에너지드링크 (약 100mg)')),
                DropdownMenuItem(value: '콜라', child: Text('콜라 (약 40mg)')),
                DropdownMenuItem(value: '녹차', child: Text('녹차 (약 20mg)')),
              ],
              onChanged: _onDrinkTypeChanged,
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
