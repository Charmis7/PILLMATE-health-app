import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {

  static final _db = FirebaseFirestore.instance;

  //read user profile
  static Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  // saveor update user profile
  static Future<void> updateUser(UserModel user) async {
    await _db
        .collection('users')
        .doc(user.uid)
        .set(user.toMap(), SetOptions(merge: true));
  }
}