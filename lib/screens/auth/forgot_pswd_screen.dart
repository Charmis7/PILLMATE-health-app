import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pillmate_college/screens/auth/reusable_widgets.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController emailController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        children: [
          const SizedBox(height: 80),


          Image.asset('assets/images/img_9.png', height: 200),
          const SizedBox(height: 30),
          const Text(
            "Forgot Password?",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Enter your email to receive a password reset link",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 40),
          const Text(
            "Enter Email",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
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

  void sendResetLink() async {
    String email = emailController.text.trim();
    if (email.isEmpty) {
      showError("Please enter your email");
      return;
    }

    if (!email.contains("@")) {
      showError("Please enter a valid email");
      return;
    }
    setState(() {
      isLoading = true;
    });

    try {
      await auth.sendPasswordResetEmail(email: email);
      showSuccess("Password reset link sent to $email");
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });

    } on FirebaseAuthException catch (error) {
      String errorMessage = "An error occurred";

      if (error.code == 'user-not-found') {
        errorMessage = "No user found with this email";
      } else if (error.code == 'invalid-email') {
        errorMessage = "Invalid email address";
      }

      showError(errorMessage);

    } catch (error) {
      showError("An error occurred: $error");
    }
    setState(() {
      isLoading = false;
    });
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}