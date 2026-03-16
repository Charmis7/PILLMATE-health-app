import 'package:flutter/material.dart';
import 'package:pillmate_college/screens/login_screen.dart';
import '../widget/reusable_widgets.dart';
import 'auth_controller.dart';

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

  // Auth controller instance
  final AuthController authController = AuthController();

  // UI state
  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      imagePath: 'assets/images/topimg.png',
      child: Column(
        children: [
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
                  hidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
                  hideConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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

          // Sign up button
          isLoading
              ? const CircularProgressIndicator()
              : PrimaryButton(
            text: "Sign up",
            onPressed: signUpWithEmail,
          ),

          const SizedBox(height: 30),

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

  // Sign up with email
  void signUpWithEmail() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    // Validation
    if (name.isEmpty) {
      showError("Please enter your name");
      return;
    }

    if (email.isEmpty) {
      showError("Please enter your email");
      return;
    }

    if (!email.contains("@")) {
      showError("Please enter a valid email");
      return;
    }

    if (password.isEmpty) {
      showError("Please enter your password");
      return;
    }

    if (password.length < 8) {
      showError("Password must be at least 8 characters");
      return;
    }

    if (confirmPassword.isEmpty) {
      showError("Please confirm your password");
      return;
    }

    if (password != confirmPassword) {
      showError("Passwords do not match");
      return;
    }

    // Call auth controller
    final error = await authController.signUp(
      name: name,
      email: email,
      password: password,
      onLoadingChanged: (loading) {
        setState(() {
          isLoading = loading;
        });
      },
    );

    // Check result
    if (error == null) {
      showSuccess("Account created successfully!");
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
    } else {
      showError(error);
    }
  }

  // Sign up with Google
  void signUpWithGoogle() async {
    final error = await authController.signUpWithGoogle(
      onLoadingChanged: (loading) {
        setState(() {
          isLoading = loading;
        });
      },
    );

    if (error == null) {
      showSuccess("Account created successfully!");
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
    } else {
      if (error != "Signup cancelled") {
        showError(error);
      }
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}