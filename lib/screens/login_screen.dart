import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../widget/reusable_widgets.dart';
import 'forgot_pswd_screen.dart';
import 'setting_profile_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Text field controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Firebase instances
  FirebaseAuth auth = FirebaseAuth.instance;
  GoogleSignIn googleSignIn = GoogleSignIn();

  // UI state variables
  bool rememberMe = false;
  bool hidePassword = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      imagePath: 'assets/images/topimg.png',
      child: Column(
        children: [
          // Title
          const Text(
            "Welcome back",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),

          // Email field
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "example@gmail.com",
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Password field
          TextField(
            controller: passwordController,
            obscureText: hidePassword,
            decoration: InputDecoration(
              hintText: "Password",
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  hidePassword ? Icons.visibility_off : Icons.visibility,
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

          // Remember me and Forgot password row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Remember me checkbox
              Row(
                children: [
                  Checkbox(
                    value: rememberMe,
                    onChanged: (value) {
                      setState(() {
                        rememberMe = value!;
                      });
                    },
                  ),
                  const Text("Remember me", style: TextStyle(fontSize: 12)),
                ],
              ),

              // Forgot password button
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Login button (shows loading spinner when loading)
          isLoading
              ? const CircularProgressIndicator()
              : PrimaryButton(
            text: "Login",
            onPressed: loginWithEmail,
          ),

          const SizedBox(height: 30),

          // Divider text
          const Center(
            child: Text(
              "- Or Sign In With -",
              style: TextStyle(color: Colors.grey),
            ),
          ),

          const SizedBox(height: 15),

          // Google sign in button
          GestureDetector(
            onTap: loginWithGoogle,
            child: Image.asset('assets/images/google.png', height: 40),
          ),

          const SizedBox(height: 30),

          // Sign up link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account? "),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Sign up",
                  style: TextStyle(
                    color: Colors.brown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Login with email and password
  void loginWithEmail() async {
    // Get text from controllers
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

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

    // Show loading spinner
    setState(() {
      isLoading = true;
    });

    try {
      // Try to login with Firebase
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // If successful, show success message
      showSuccess("Login Successful!");

      // Wait a bit and go to home screen
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SettingProfileScreen(),
          ),
        );
      });
    } on FirebaseAuthException catch (error) {
      // If login fails, show error message
      String errorMessage = "Login failed";

      if (error.code == 'user-not-found') {
        errorMessage = "No user found with this email";
      } else if (error.code == 'wrong-password') {
        errorMessage = "Wrong password";
      } else if (error.code == 'invalid-email') {
        errorMessage = "Invalid email address";
      } else if (error.code == 'user-disabled') {
        errorMessage = "This account has been disabled";
      } else if (error.code == 'invalid-credential') {
        errorMessage = "Invalid email or password";
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

  // Login with Google
  void loginWithGoogle() async {
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
      await auth.signInWithCredential(credential);

      // Show success message
      showSuccess("Login Successful!");

      // Go to home screen
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SettingProfileScreen(),
          ),
        );
      });
    } catch (error) {
      // If Google sign in fails
      showError("Google sign in failed: $error");
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
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Show success message (green snackbar)
  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Clean up controllers when screen is closed
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}