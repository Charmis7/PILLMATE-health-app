

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';


class AuthService {

  final _auth      = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();



  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // create acc
      final cred = await _auth.createUserWithEmailAndPassword(
      email: email, password: password,
      );

      //save user data
     await _firestore.collection('users').doc(cred.user!.uid).set({
        'uid'      : cred.user!.uid,
        'name'     : name,
        'email'    : email,
        'createdAt': DateTime.now().toIso8601String(),
      });

      // send email ver
     await cred.user?.sendEmailVerification();

      return null; // null = success

    } on FirebaseAuthException catch (e)//catches only fb-specific errors like wrong pswd ,invalid or used email
    {
      return _errorMessage(e);
    } catch (e)// other-like network crash or unknown bugs
    {
      return 'Something went wrong. Please try again.';
    }
  }

  //login
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // null = success
    } on FirebaseAuthException catch (e) {
      return _errorMessage(e);
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }
  //google

  // Google login
  Future<String?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return 'Cancelled by user';

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      final userDoc = _firestore.collection('users').doc(userCredential.user!.uid);
      final docSnapshot = await userDoc.get();
      if (!docSnapshot.exists) {
        await userDoc.set({
          'uid': userCredential.user!.uid,
          'name': userCredential.user!.displayName ?? '',
          'email': userCredential.user!.email ?? '',
          'createdAt': DateTime.now().toIso8601String(),
        });
      }

      return null; // success
    } on FirebaseAuthException catch (e) {
      return _errorMessage(e);
    } catch (e) {
      return 'Something went wrong with Google sign-in.';
    }
  }

 //forgot pswd
  Future<String?> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _errorMessage(e);
    } catch (e) {
      return 'Failed to send reset email.';
    }
  }

//logout
Future<void> logout() async => _auth.signOut();

 //idk
  User? get currentUser => _auth.currentUser;//getter-return currently logged in user only thats why get

 //error msg
  String _errorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found'      : return 'No account found with this email.';
      case 'wrong-password'      : return 'Incorrect password.';
      case 'email-already-in-use': return 'Email already registered.';
      case 'invalid-email'       : return 'Invalid email address.';
      case 'weak-password'       : return 'Password is too weak.';
      case 'user-disabled'       : return 'This account has been disabled.';
      case 'invalid-credential'  : return 'Invalid email or password.';
      default                    : return e.message ?? 'Authentication failed.';
    }
  }
}
