// ════════════════════════════════════════════════════════════════════════════
// firestore_base.dart
//
// PURPOSE  : One place that knows HOW to build a Firestore path for the
//            current user.  Every service (medicine, tracker, wellbeing)
//            calls _userCol(subCollection) instead of repeating the same
//            4-line path every time.
//
// WHY?     : DRY principle — Don't Repeat Yourself.
//            If the Firestore path ever changes you fix it here, not in
//            every single service file.
//
// PATTERN  : This is the standard "repository" pattern used in almost every
//            Flutter + Firestore app — yes, it IS boilerplate that you can
//            copy to any new project.
//
// FIRESTORE STRUCTURE (one user):
//   users/
//     └── {uid}/               ← one doc per logged-in user
//           ├── medicines/     ← subcollection
//           ├── trackers/      ← subcollection
//           └── wellbeing/     ← subcollection
// ════════════════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart'; // gives us Firestore
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreBase {


  static final _db   = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;
  static String get _uid => _auth.currentUser!.uid;

  static CollectionReference userCol(String subCollection) {
    return _db
        .collection('users')
        .doc(_uid)
        .collection(subCollection);
  }

 //build date key
  static String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
