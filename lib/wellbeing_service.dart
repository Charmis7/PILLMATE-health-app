import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WellbeingEntry {
  final String id;
  final DateTime date;
  final String time;
  final String mood;
  final String symptoms;

  WellbeingEntry({
    required this.id,
    required this.date,
    required this.time,
    required this.mood,
    required this.symptoms,
  });

  Map<String, dynamic> toMap() => {
    'date': Timestamp.fromDate(date),
    'time': time,
    'mood': mood,
    'symptoms': symptoms,
  };

  factory WellbeingEntry.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WellbeingEntry(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      time: data['time'] ?? '',
      mood: data['mood'] ?? '',
      symptoms: data['symptoms'] ?? '',
    );
  }
}

class WellbeingService {
  static CollectionReference _col() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('wellbeing');
  }

  // Save entry
  static Future<void> saveEntry(WellbeingEntry entry) async {
    await _col().add(entry.toMap());
  }

  // Stream all entries live
  static Stream<List<WellbeingEntry>> streamEntries() {
    return _col()
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => WellbeingEntry.fromDoc(d)).toList());
  }

  // Delete entry
  static Future<void> deleteEntry(String docId) async {
    await _col().doc(docId).delete();
  }
}