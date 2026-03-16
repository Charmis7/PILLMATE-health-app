import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up with email & password
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

      // Update display name
      await userCred.user?.updateDisplayName(name);

      // Save user data to Firestore
      await _firestore.collection('users').doc(userCred.user!.uid).set({
        'uid': userCred.user!.uid,
        'name': name,
        'email': email,
        'phoneNumber': null,
        'profilePicUrl': null,
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Send verification email
      await userCred.user?.sendEmailVerification();

      return null; // Success (no error)

    } on FirebaseAuthException catch (e) {
      // Handle Firebase errors
      if (e.code == 'email-already-in-use') {
        return "This email is already registered";
      } else if (e.code == 'weak-password') {
        return "Password is too weak";
      } else if (e.code == 'invalid-email') {
        return "Invalid email address";
      }
      return e.message;
    } catch (e) {
      return "Error: $e";
    }
  }

  // Login with email & password
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with Firebase
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return null; // Success (no error)

    } on FirebaseAuthException catch (e) {
      // Handle Firebase errors
      if (e.code == 'user-not-found') {
        return "No user found with this email";
      } else if (e.code == 'wrong-password') {
        return "Wrong password";
      } else if (e.code == 'invalid-email') {
        return "Invalid email address";
      } else if (e.code == 'user-disabled') {
        return "This account has been disabled";
      } else if (e.code == 'invalid-credential') {
        return "Invalid email or password";
      }
      return e.message;
    } catch (e) {
      return "Error: $e";
    }
  }

  // Sign up with Google
  Future<String?> signUpWithGoogle() async {
    try {
      // Trigger Google sign-in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return "Signup cancelled"; // User cancelled
      }

      // Get Google auth credentials
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      UserCredential userCred = await _auth.signInWithCredential(credential);

      // Check if user exists in Firestore
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userCred.user!.uid)
          .get();

      // If new user, create Firestore document
      if (!doc.exists) {
        await _firestore.collection('users').doc(userCred.user!.uid).set({
          'uid': userCred.user!.uid,
          'name': userCred.user!.displayName ?? 'User',
          'email': userCred.user!.email ?? '',
          'phoneNumber': userCred.user!.phoneNumber,
          'profilePicUrl': userCred.user!.photoURL,
          'createdAt': DateTime.now().toIso8601String(),
        });
      }

      return null; // Success

    } catch (e) {
      return "Google signup failed: $e";
    }
  }

  // Login with Google
  Future<String?> loginWithGoogle() async {
    try {
      // Trigger Google sign-in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return "Login cancelled"; // User cancelled
      }

      // Get Google auth credentials
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      await _auth.signInWithCredential(credential);

      return null; // Success

    } catch (e) {
      return "Google login failed: $e";
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Send password reset email
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return "No user found with this email";
      } else if (e.code == 'invalid-email') {
        return "Invalid email address";
      }
      return e.message;
    } catch (e) {
      return "Error: $e";
    }
  }
}