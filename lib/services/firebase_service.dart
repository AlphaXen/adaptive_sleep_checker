import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_params.dart';
import '../models/sleep_log.dart';
import '../models/caffeine_log.dart';

class FirebaseService {
  FirebaseService();

  String get uid => FirebaseAuth.instance.currentUser!.uid;
  final db = FirebaseFirestore.instance;

  Future<UserParams> getParams() async {
    final doc = await db.collection('users').doc(uid).get();
    if (!doc.exists) {
      final params = UserParams();
      await db.collection('users').doc(uid).set(params.toMap());
      return params;
    }
    return UserParams.fromMap(doc.data()!);
  }

  Future<void> saveParams(UserParams params) async {
    await db.collection('users').doc(uid).set(params.toMap());
  }

  Future<void> addSleepLog(SleepLog log) async {
    await db
        .collection('users')
        .doc(uid)
        .collection('sleep_logs')
        .doc(log.date.toIso8601String())
        .set(log.toMap());
  }

  Future<List<SleepLog>> getRecentSleepLogs({int days = 7}) async {
    final now = DateTime.now();
    final from = now.subtract(Duration(days: days));
    final q = await db
        .collection('users')
        .doc(uid)
        .collection('sleep_logs')
        .where('date', isGreaterThanOrEqualTo: from.toIso8601String())
        .get();
    return q.docs.map((e) => SleepLog.fromMap(e.data())).toList();
  }

  Future<void> addCaffeineLog(CaffeineLog log) async {
    await db
        .collection('users')
        .doc(uid)
        .collection('caffeine_logs')
        .doc(log.timestamp.toIso8601String())
        .set(log.toMap());
  }

  Future<List<CaffeineLog>> getTodayCaffeineLogs() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final q = await db
        .collection('users')
        .doc(uid)
        .collection('caffeine_logs')
        .where('timestamp',
            isGreaterThanOrEqualTo: todayStart.toIso8601String())
        .get();
    return q.docs.map((e) => CaffeineLog.fromMap(e.data())).toList();
  }

  // === Custom-day range based on user-defined dayStartHour ===

  Future<List<SleepLog>> getSleepLogsForCustomDay(
      DateTime customDay, int dayStartHour) async {
    final start = DateTime(
        customDay.year, customDay.month, customDay.day, dayStartHour);
    final end = start.add(const Duration(days: 1));
    final q = await db
        .collection('users')
        .doc(uid)
        .collection('sleep_logs')
        .where('sleepStart',
            isGreaterThanOrEqualTo: start.toIso8601String())
        .where('sleepStart', isLessThan: end.toIso8601String())
        .get();
    return q.docs.map((e) => SleepLog.fromMap(e.data())).toList();
  }

  Future<List<CaffeineLog>> getCaffeineLogsForCustomDay(
      DateTime customDay, int dayStartHour) async {
    final start = DateTime(
        customDay.year, customDay.month, customDay.day, dayStartHour);
    final end = start.add(const Duration(days: 1));
    final q = await db
        .collection('users')
        .doc(uid)
        .collection('caffeine_logs')
        .where('timestamp',
            isGreaterThanOrEqualTo: start.toIso8601String())
        .where('timestamp', isLessThan: end.toIso8601String())
        .get();
    return q.docs.map((e) => CaffeineLog.fromMap(e.data())).toList();
  }
}
