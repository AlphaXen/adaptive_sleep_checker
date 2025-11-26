import 'package:flutter/material.dart';
import '../models/recommendation.dart';

class RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;

  const RecommendationCard({super.key, required this.recommendation});

  String _format(DateTime dt) {
    return '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '내일 수면 추천 결과',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.nightlight_round),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '메인 수면: ${_format(recommendation.mainSleepStart)} ~ '
                    '${_format(recommendation.mainSleepEnd)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.coffee),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '카페인 컷오프: ${_format(recommendation.caffeineCutoff)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone_iphone),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '취침 준비 시작: ${_format(recommendation.winddownStart)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.light_mode),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recommendation.lightPlanSummary,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
