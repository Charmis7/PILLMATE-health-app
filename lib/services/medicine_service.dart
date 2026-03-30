import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/medicine_model.dart';

class MedicineService {

  // Path: users/{uid}/medicines
  static CollectionReference get _col => FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('medicines');

  //save new medicine → returns the new doc ID
  static Future<String> saveMedicine(MedicineEntry entry) async {
    final ref = await _col.add(entry.toMap());
    return ref.id;
  }

  // Real-time list —ui rebuilds on every change
  static Stream<List<MedicineEntry>> streamMedicines() {
    return _col
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => MedicineEntry.fromDoc(doc))
        .toList());
  }

  // mark med as taken
  static Future<void> markTakenToday(String docId) async {
    final today = _today();
    await _col.doc(docId).update({
      'takenDates': FieldValue.arrayUnion([today]),
    });
  }

  // remove from taken
  static Future<void> unmarkTaken(String docId) async {
    final today = _today();
    await _col.doc(docId).update({
      'takenDates': FieldValue.arrayRemove([today]),
    });
  }

//delete med
  static Future<void> deleteMedicine(String docId) async {
    await _col.doc(docId).delete();
  }

  static String _today() {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}