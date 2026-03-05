import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widget/reusable_widgets.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Text field controller
  TextEditingController emailController = TextEditingController();

  // Firebase instance
  FirebaseAuth auth = FirebaseAuth.instance;

  // Loading state
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        children: [
          const SizedBox(height: 80),

          // Image
          Image.asset('assets/images/img_9.png', height: 200),
          const SizedBox(height: 30),

          // Title
          const Text(
            "Forgot Password?",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Subtitle
          const Text(
            "Enter your email to receive a password reset link",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 40),

          // Label
          const Text(
            "Enter Email",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Email text field
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "example@gmail.com",
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Send reset link button (shows loading spinner when loading)
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : PrimaryButton(
            text: "Send Reset Link",
            onPressed: sendResetLink,
          ),
        ],
      ),
    );
  }

  // Send password reset email
  void sendResetLink() async {
    // Get email from text field
    String email = emailController.text.trim();

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

    // Show loading spinner
    setState(() {
      isLoading = true;
    });

    try {
      // Send password reset email through Firebase
      await auth.sendPasswordResetEmail(email: email);

      // Show success message
      showSuccess("Password reset link sent to $email");

      // Wait 2 seconds and go back to login screen
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });

    } on FirebaseAuthException catch (error) {
      // If Firebase returns an error, show appropriate message
      String errorMessage = "An error occurred";

      if (error.code == 'user-not-found') {
        errorMessage = "No user found with this email";
      } else if (error.code == 'invalid-email') {
        errorMessage = "Invalid email address";
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

  // Show error message (red snackbar)
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show success message (green snackbar)
  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Clean up controller when screen is closed
  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}