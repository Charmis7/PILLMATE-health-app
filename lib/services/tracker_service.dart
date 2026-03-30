// ════════════════════════════════════════════════════════════════════════════
// tracker_service.dart
//
// PURPOSE  : Firestore CRUD for tracker entries (measurements + activities).
//            Same 3-method pattern as MedicineService — save / stream / delete.
//            Firestore path: users/{uid}/trackers
// ════════════════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_base.dart';
import '../models/tracker_model.dart';

class TrackerService {

  static CollectionReference get _col => FirestoreBase.userCol('trackers');

  static Future<String> saveTracker(TrackerEntry entry) async {
    final ref = await _col.add(entry.toMap());
    return ref.id; // use this ID to cancel the notification later
  }

 //i dont get this one
  static Stream<List<TrackerEntry>> streamTrackers() {
    return _col
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => TrackerEntry.fromDoc(d))
            .toList());
  }


  static Future<void> deleteTracker(String docId) async {
    await _col.doc(docId).delete();
  }
}
