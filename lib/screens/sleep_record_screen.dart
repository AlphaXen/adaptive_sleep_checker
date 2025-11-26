import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/sleep_service.dart';

class SleepRecordScreen extends StatelessWidget {
  SleepRecordScreen({super.key});

  final service = SleepService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("수면 기록")),
      body: StreamBuilder(
        stream: service.pendingCol.orderBy('createdAt', descending: true).snapshots(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("새로운 자동 수면 추정 기록이 없습니다."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (ctx, index) {
              final p = docs[index];

              final start = DateTime.fromMillisecondsSinceEpoch(p['predictedStart']);
              final end = DateTime.fromMillisecondsSinceEpoch(p['predictedEnd']);

              return Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("휴대폰 센서 기반 자동 추정",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("수면 시작: ${start.toLocal()}"),
                      Text("기상 시간: ${end.toLocal()}"),
                      const SizedBox(height: 16),
                      const Text("실제 수면 시간을 확인하고 저장해주세요."),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () =>
                                _editRecord(context, p),
                            child: const Text("수정하기"),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () =>
                                _saveRecord(p, edited: false),
                            child: const Text("저장하기"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _saveRecord(DocumentSnapshot p, {required bool edited}) async {
    await service.confirmSleepRecord(
      start: p['predictedStart'],
      end: p['predictedEnd'],
      pendingId: p.id,
      edited: edited,
    );
  }

  Future<void> _editRecord(BuildContext context, DocumentSnapshot p) async {
    final startDT = DateTime.fromMillisecondsSinceEpoch(p['predictedStart']);
    final endDT = DateTime.fromMillisecondsSinceEpoch(p['predictedEnd']);

    // 수정용 타임피커
    final newStart = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(startDT),
    );
    if (newStart == null) return;

    final newEnd = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(endDT),
    );
    if (newEnd == null) return;

    final editedStart = DateTime(
      startDT.year, startDT.month, startDT.day,
      newStart.hour, newStart.minute,
    ).millisecondsSinceEpoch;

    final editedEnd = DateTime(
      endDT.year, endDT.month, endDT.day,
      newEnd.hour, newEnd.minute,
    ).millisecondsSinceEpoch;

    await service.confirmSleepRecord(
      start: editedStart,
      end: editedEnd,
      pendingId: p.id,
      edited: true,
    );
  }
}
