import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pillmate_college/screens/login_screen.dart';
import '../widget/reusable_widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Text field controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  // Firebase instances
  FirebaseAuth auth = FirebaseAuth.instance;
  GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // UI state variables
  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      imagePath: 'assets/images/topimg.png',
      child: Column(
        children: [
          // Title
          const Text(
            "Create your Account",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),

          // Name field
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: "Name",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Email field
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: "Email",
              hintText: "example@gmail.com",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Password field
          TextField(
            controller: passwordController,
            obscureText: hidePassword,
            decoration: InputDecoration(
              labelText: "Password",
              suffixIcon: IconButton(
                icon: Icon(
                  hidePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () {
                  setState(() {
                    hidePassword = !hidePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Confirm password field
          TextField(
            controller: confirmPasswordController,
            obscureText: hideConfirmPassword,
            decoration: InputDecoration(
              labelText: "Confirm Password",
              suffixIcon: IconButton(
                icon: Icon(
                  hideConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () {
                  setState(() {
                    hideConfirmPassword = !hideConfirmPassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Sign up button (shows loading spinner when loading)
          isLoading
              ? const CircularProgressIndicator()
              : PrimaryButton(
            text: "Sign up",
            onPressed: signUpWithEmail,
          ),

          const SizedBox(height: 30),

          // Divider text
          const Center(
            child: Text(
              "- Or Sign Up With -",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 15),

          // Google sign up button
          GestureDetector(
            onTap: signUpWithGoogle,
            child: Image.asset('assets/images/google.png', height: 40),
          ),
        ],
      ),
    );
  }

  // Sign up with email and password
  void signUpWithEmail() async {
    // Get text from controllers
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    // Check if name is empty
    if (name.isEmpty) {
      showError("Please enter your name");
      return;
    }

    // Check if email is empty
    if (email.isEmpty) {
      showError("Please enter your email");
      return;
    }

    // Check if email is valid
    if (!email.contains("@")) {
      showError("Please enter a valid email");
      return;
    }

    // Check if password is empty
    if (password.isEmpty) {
      showError("Please enter your password");
      return;
    }

    // Check if password is long enough
    if (password.length < 8) {
      showError("Password must be at least 8 characters");
      return;
    }

    // Check if confirm password is empty
    if (confirmPassword.isEmpty) {
      showError("Please confirm your password");
      return;
    }

    // Check if passwords match
    if (password != confirmPassword) {
      showError("Passwords do not match");
      return;
    }

    // Show loading spinner
    setState(() {
      isLoading = true;
    });

    try {
      // Step 1: Create user account in Firebase Authentication
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Step 2: Update user's display name
      await userCredential.user?.updateDisplayName(name);

      // Step 3: Save user data to Firestore database
      await firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': name,
        'email': email,
        'phoneNumber': null,
        'profilePicUrl': null,
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Step 4: Send verification email (optional)
      await userCredential.user?.sendEmailVerification();

      // Show success message
      showSuccess("Account created successfully!");

      // Wait 2 seconds and go to login screen
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      });
    } on FirebaseAuthException catch (error) {
      // If signup fails, show error message
      String errorMessage = "Sign up failed";

      if (error.code == 'email-already-in-use') {
        errorMessage = "This email is already registered";
      } else if (error.code == 'invalid-email') {
        errorMessage = "Invalid email address";
      } else if (error.code == 'weak-password') {
        errorMessage = "Password is too weak";
      }

      showError(errorMessage);
    } catch (error) {
      // If something else goes wrong
      showError("An error occurred: $error");
    }

    // Hide loading spinner
    setState(() {
      isLoading = false;
    });
  }

  // Sign up with Google
  void signUpWithGoogle() async {
    // Show loading spinner
    setState(() {
      isLoading = true;
    });

    try {
      // Step 1: Show Google sign in popup
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // If user cancels, stop here
      if (googleUser == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Step 2: Get authentication details from Google
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Step 3: Create Firebase credential from Google auth
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Step 4: Sign in to Firebase with Google credential
      UserCredential userCredential = await auth.signInWithCredential(credential);

      // Step 5: Check if user already exists in Firestore
      DocumentSnapshot userDoc = await firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      // Step 6: If user doesn't exist, create their profile
      if (!userDoc.exists) {
        await firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'name': userCredential.user!.displayName ?? 'User',
          'email': userCredential.user!.email ?? '',
          'phoneNumber': userCredential.user!.phoneNumber,
          'profilePicUrl': userCredential.user!.photoURL,
          'createdAt': DateTime.now().toIso8601String(),
        });
      }

      // Show success message
      showSuccess("Account created successfully!");

      // Wait 2 seconds and go to login screen
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      });
    } catch (error) {
      // If Google sign up fails
      showError("Google sign up failed: $error");
    }

    // Hide loading spinner
    setState(() {
      isLoading = false;
    });
  }

  // Show error message (red snackbar)
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Show success message (green snackbar)
  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Clean up controllers when screen is closed
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}