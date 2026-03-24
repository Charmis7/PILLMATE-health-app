// ════════════════════════════════════════════════════════════════════════════
// medicine_service.dart
// PURPOSE : All Firestore read/write operations for medicines.
//           Save, stream (real-time list), mark taken, undo taken, delete.
//
// PATTERN : Every method builds the path users/{uid}/medicines first,
//           then performs one Firestore operation on that path.
// ════════════════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart'; // PACKAGE: cloud_firestore
import 'package:firebase_auth/firebase_auth.dart';

import 'model/medicine_model.dart';     // PACKAGE: firebase_auth — to get current user's uid


class MedicineService {

  // ── Path builder ──────────────────────────────────────────────────────────
  // FIRESTORE: builds the path to this user's medicines subcollection.
  //            Path = users/{uid}/medicines
  //            Using uid in the path means User A can NEVER access User B's data.
  static CollectionReference _col() { // CollectionReference = FIRESTORE TYPE
    final uid = FirebaseAuth.instance.currentUser!.uid; // FIREBASE AUTH: get current user's uid
    return FirebaseFirestore.instance                   // FIRESTORE: get Firestore instance
        .collection('users')                            // FIRESTORE: 'users' collection
        .doc(uid)                                       // FIRESTORE: this user's document
        .collection('medicines');                       // FIRESTORE: their medicines sub-collection
  }

  // ── SAVE a new medicine ────────────────────────────────────────────────────
  // FIRESTORE: .add() creates a new document with an auto-generated random ID.
  //            Returns a DocumentReference — we use ref.id to get the new ID.
  //            That ID is then used to schedule notifications linked to this medicine.
  static Future<String> saveMedicine(MedicineEntry entry) async {
    final ref = await _col().add(entry.toMap()); // FIRESTORE METHOD: .add() = create with auto-ID
    return ref.id;                               // FIRESTORE: ref.id = the new auto-generated document ID
  }

  // ── STREAM all medicines (real-time) ──────────────────────────────────────
  // FIRESTORE: .snapshots() returns a Stream — a continuous pipe of data.
  //            Every time ANY medicine is added/edited/deleted in Firestore,
  //            this stream emits a new list automatically.
  //            The UI rebuilds without any manual refresh.
  static Stream<List<MedicineEntry>> streamMedicines() {
    return _col()
        .snapshots()                                                     // FIRESTORE METHOD: .snapshots() = real-time stream
        .map((snap) => snap.docs                                         // snap.docs = list of all documents
        .map((doc) => MedicineEntry.fromDoc(doc))                   // convert each raw doc → MedicineEntry
        .toList());
  }

  // ── MARK taken today ──────────────────────────────────────────────────────
  // FIRESTORE: FieldValue.arrayUnion() adds an item to an array IN Firestore atomically.
  //            'Atomically' = safe even if two devices update at the exact same time.
  //            We NEVER read the array first — Firebase handles the add safely.
  static Future<void> markTakenToday(String docId) async {
    final today = _dateKey(DateTime.now());
    await _col().doc(docId).update({                          // FIRESTORE METHOD: .update() = update specific fields
      'takenDates': FieldValue.arrayUnion([today]),           // FIRESTORE: arrayUnion = add to array safely
    });
  }

  // ── UNDO taken today ──────────────────────────────────────────────────────
  // FIRESTORE: FieldValue.arrayRemove() removes an item from an array atomically.
  static Future<void> unmarkTaken(String docId) async {
    final today = _dateKey(DateTime.now());
    await _col().doc(docId).update({                          // FIRESTORE METHOD: .update()
      'takenDates': FieldValue.arrayRemove([today]),          // FIRESTORE: arrayRemove = remove from array safely
    });
  }

  // ── DELETE a medicine ─────────────────────────────────────────────────────
  // FIRESTORE: .delete() permanently removes the document.
  //            Call NotificationService.cancelMedicineNotifications() BEFORE this
  //            so the phone alarm is also cancelled.
  static Future<void> deleteMedicine(String docId) async {
    await _col().doc(docId).delete(); // FIRESTORE METHOD: .delete() = remove document permanently
  }

  // ── Helper ────────────────────────────────────────────────────────────────
  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}