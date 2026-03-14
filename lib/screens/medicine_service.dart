import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'medicine_model.dart';

class MedicineService {
  static final _db = FirebaseFirestore.instance;

  // Get current user's medicines collection
  static CollectionReference _userMeds() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _db.collection('users').doc(uid).collection('medicines');
  }

  // Save a new medicine → returns the new Firestore doc ID
  static Future<String> saveMedicine(MedicineEntry entry) async {
    final ref = await _userMeds().add(entry.toMap());
    return ref.id;
  }

  // Stream all medicines for HomeScreen (real-time)
  static Stream<List<MedicineEntry>> streamMedicines() {
    return _userMeds().snapshots().map(
          (snap) => snap.docs.map((d) => MedicineEntry.fromDoc(d)).toList(),
    );
  }

  // Mark medicine as taken today
  static Future<void> markTakenToday(String docId) async {
    final today = _dateKey(DateTime.now());
    await _userMeds().doc(docId).update({
      'takenDates': FieldValue.arrayUnion([today]),
    });
  }

  // Unmark (undo taken)
  static Future<void> unmarkTaken(String docId) async {
    final today = _dateKey(DateTime.now());
    await _userMeds().doc(docId).update({
      'takenDates': FieldValue.arrayRemove([today]),
    });
  }

  // Delete medicine permanently
  static Future<void> deleteMedicine(String docId) async {
    await _userMeds().doc(docId).delete();
  }

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}