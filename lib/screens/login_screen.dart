import 'package:flutter/material.dart';
import '../widget/reusable_widgets.dart';
import 'auth_controller.dart';
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

  // Auth controller instance
  final AuthController authController = AuthController();

  // UI state
  bool rememberMe = false;
  bool hidePassword = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      imagePath: 'assets/images/topimg.png',
      child: Column(
        children: [
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

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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

          // Login button
          isLoading
              ? const CircularProgressIndicator()
              : PrimaryButton(
            text: "Login",
            onPressed: loginWithEmail,
          ),

          const SizedBox(height: 30),

          const Center(
            child: Text(
              "- Or Sign In With -",
              style: TextStyle(color: Colors.grey),
            ),
          ),

          const SizedBox(height: 15),

          GestureDetector(
            onTap: loginWithGoogle,
            child: Image.asset('assets/images/google.png', height: 40),
          ),

          const SizedBox(height: 30),

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

  // Login with email
  void loginWithEmail() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // Validation
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

    // Call auth controller
    final error = await authController.login(
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
      showSuccess("Login Successful!");
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SettingProfileScreen(),
          ),
        );
      });
    } else {
      showError(error);
    }
  }

  // Login with Google
  void loginWithGoogle() async {
    final error = await authController.loginWithGoogle(
      onLoadingChanged: (loading) {
        setState(() {
          isLoading = loading;
        });
      },
    );

    if (error == null) {
      showSuccess("Login Successful!");
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SettingProfileScreen(),
          ),
        );
      });
    } else {
      if (error != "Login cancelled") {
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
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}