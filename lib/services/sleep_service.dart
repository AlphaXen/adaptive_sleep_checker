import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SleepService {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final fs = FirebaseFirestore.instance;

  CollectionReference get pendingCol =>
      fs.collection('users').doc(uid).collection('pendingSleepRecords');

  CollectionReference get sleepCol =>
      fs.collection('users').doc(uid).collection('sleepRecords');

  Future<void> addPendingSleep(int start, int end) async {
    await pendingCol.add({
      'predictedStart': start,
      'predictedEnd': end,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'source': 'auto',
    });
  }

  Future<void> confirmSleepRecord({
    required int start,
    required int end,
    required String pendingId,
    required bool edited,
  }) async {
    await sleepCol.add({
      'sleepStart': start,
      'sleepEnd': end,
      'confirmed': true,
      'edited': edited,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });

    await pendingCol.doc(pendingId).delete();
  }
}
