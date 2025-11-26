import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/sleep_service.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("타임라인"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildSleepHistorySection(),
            const SizedBox(height: 24),
            _buildCaffeineSection(),
          ],
        ),
      ),
    );
  }

  // ---------------------------
  // ✔ 수면 기록 타임라인
  // ---------------------------
  Widget _buildSleepHistorySection() {
    final service = SleepService();

    return StreamBuilder(
      stream: service.sleepCol.orderBy('sleepStart', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Text("저장된 수면 기록이 없습니다.");
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "🛌 수면 기록",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...docs.map((e) {
              final start =
                  DateTime.fromMillisecondsSinceEpoch(e['sleepStart']);
              final end =
                  DateTime.fromMillisecondsSinceEpoch(e['sleepEnd']);
              final duration = end.difference(start);

              return _TimelineBlock(
                icon: Icons.bed_rounded,
                color: Colors.indigo,
                title: "${_format(start)} ~ ${_format(end)}",
                subtitle:
                    "수면 ${duration.inHours}시간 ${duration.inMinutes % 60}분",
              );
            }).toList(),
          ],
        );
      },
    );
  }

  // ---------------------------
  // ✔ 카페인 기록 (예시용)
  // ---------------------------
  Widget _buildCaffeineSection() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('caffeineLogs')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Text("카페인 기록이 없습니다.");
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text(
              "☕ 카페인 섭취 기록",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...docs.map((e) {
              final time =
                  DateTime.fromMillisecondsSinceEpoch(e['timestamp']);

              return _TimelineBlock(
                icon: Icons.local_cafe,
                color: Colors.brown,
                title: _format(time),
                subtitle: "${e['drinkType']} · ${e['amount']}mg",
              );
            }).toList(),
          ],
        );
      },
    );
  }

  // ✔ 시간 표시 helper
  String _format(DateTime dt) {
    final f = DateFormat("MM/dd HH:mm");
    return f.format(dt);
  }
}

//////////////////////////////////////
// Timeline Block 위젯
//////////////////////////////////////
class _TimelineBlock extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _TimelineBlock({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(30, 0, 0, 0),
            blurRadius: 8,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey.shade700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
