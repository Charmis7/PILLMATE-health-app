// ════════════════════════════════════════════════════════════════════════════
// wellbeing_service.dart
//
// PURPOSE  : Model + Firestore service for mood/symptom logs.
//            Firestore path: users/{uid}/wellbeing
//
// NOTE     : Model and service are in one file here because WellbeingEntry
//            is only ever used by WellbeingService — no need to split them.
// ════════════════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_base.dart';

class WellbeingEntry {
  final String   id;
  final DateTime date;
  final String   time;
  final String   mood;
  final String   symptoms;

  WellbeingEntry({
    required this.id,
    required this.date,
    required this.time,
    required this.mood,
    required this.symptoms,
  });

  // D->F
  Map<String, dynamic> toMap() => {
    'date'    : Timestamp.fromDate(date),
    'time'    : time,
    'mood'    : mood,
    'symptoms': symptoms,
  };

  // F doc → D
  factory WellbeingEntry.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WellbeingEntry(
      id      : doc.id,
      date    : (data['date'] as Timestamp).toDate(),
      time    : data['time']     ?? '',
      mood    : data['mood']     ?? '',
      symptoms: data['symptoms'] ?? '',
    );
  }
}

class WellbeingService {

  static CollectionReference get _col => FirestoreBase.userCol('wellbeing');

  static Future<void> saveEntry(WellbeingEntry entry) async {
    await _col.add(entry.toMap());
  }


  static Stream<List<WellbeingEntry>> streamEntries() {
    return _col
        .orderBy('date', descending: true) //new first
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => WellbeingEntry.fromDoc(d))
            .toList());
  }
//delete
  static Future<void> deleteEntry(String docId) async {
    await _col.doc(docId).delete();
  }
}
