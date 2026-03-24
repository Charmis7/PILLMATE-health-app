import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tracker_model.dart';

class TrackerService {
  static CollectionReference _col() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('trackers');
  }

  // Save tracker → returns doc ID
  static Future<String> saveTracker(TrackerEntry entry) async {
    final ref = await _col().add(entry.toMap());
    return ref.id;
  }

  // Stream all trackers live (for chart screen)
  static Stream<List<TrackerEntry>> streamTrackers() {
    return _col().snapshots().map(
          (snap) => snap.docs.map((d) => TrackerEntry.fromDoc(d)).toList(),
    );
  }

  // Delete tracker
  static Future<void> deleteTracker(String docId) async {
    await _col().doc(docId).delete();
  }
}