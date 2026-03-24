import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Sign Up with Email ──────────────────────────────────────────────────
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save display name to Firebase Auth profile
      await userCred.user?.updateDisplayName(name);

      // Save user info to Firestore under users/{uid}
      await _firestore.collection('users').doc(userCred.user!.uid).set({
        'uid': userCred.user!.uid,
        'name': name,
        'email': email,
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Send email verification
      await userCred.user?.sendEmailVerification();

      return null; // Success

    } on FirebaseAuthException catch (e) {
      return _handleError(e);
    } catch (e) {
      return "Something went wrong. Please try again.";
    }
  }

  // ── Login with Email ────────────────────────────────────────────────────
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Success

    } on FirebaseAuthException catch (e) {
      return _handleError(e);
    } catch (e) {
      return "Something went wrong. Please try again.";
    }
  }

  // ── Forgot Password ─────────────────────────────────────────────────────
  Future<String?> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _handleError(e);
    } catch (e) {
      return "Failed to send reset email.";
    }
  }

  // ── Logout ──────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ── Get current logged-in user ──────────────────────────────────────────
  User? get currentUser => _auth.currentUser;

  // ── Map Firebase error codes to readable messages ───────────────────────
  String _handleError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':       return "No account found with this email.";
      case 'wrong-password':       return "Incorrect password.";
      case 'email-already-in-use': return "Email already registered.";
      case 'invalid-email':        return "Invalid email address.";
      case 'weak-password':        return "Password is too weak.";
      case 'user-disabled':        return "This account has been disabled.";
      case 'invalid-credential':   return "Invalid email or password.";
      default:                     return e.message ?? "Authentication failed.";
    }
  }
}