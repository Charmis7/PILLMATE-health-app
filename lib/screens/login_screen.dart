

import 'package:flutter/material.dart';
import '../widget/reusable_widgets.dart';
import 'auth_service.dart';
import 'forgot_pswd_screen.dart';
import 'setting_profile_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();

  //Aathservice handles all firebase auth operations
  final _authService = AuthService();

  bool _hidePassword = true;
  bool _isLoading    = false;

  Future<void> _login() async {
    final email    = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // UI validation
    if (email.isEmpty)        { _showError("Please enter your email"); return; }
    if (!email.contains("@")) { _showError("Please enter a valid email"); return; }
    if (password.isEmpty)     { _showError("Please enter your password"); return; }
    if (password.length < 8)  { _showError("Password must be at least 8 characters"); return; }

    setState(() => _isLoading = true);

    // AUTH LOGIC: signs in with Firebase Auth
    // returns null on success, error message string on failure
    final error = await _authService.login(
      email:    email,
      password: password,
    );

    setState(() => _isLoading = false);

    if (error == null) {
      // AUTH LOGIC: null means login was successful
      _showSuccess("Login Successful!");
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SettingProfileScreen()),
        );
      }
    } else {
      _showError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      imagePath: 'assets/images/topimg.png',
      child: Column(
        children: [
          const Text("Welcome Back",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),

          // Email
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "example@gmail.com",
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
          const SizedBox(height: 20),

          // Password
          TextField(
            controller: _passwordController,
            obscureText: _hidePassword,
            decoration: InputDecoration(
              hintText: "Password",
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_hidePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _hidePassword = !_hidePassword),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),

          // Forgot password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              // AUTH LOGIC: navigates to forgot password screen
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
              ),
              child: const Text("Forgot Password?",
                  style: TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(height: 20),

          // Login button
          _isLoading
              ? const CircularProgressIndicator()
              : PrimaryButton(text: "Login", onPressed: _login),

          const SizedBox(height: 30),

          // Go to signup
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account? "),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                ),
                child: const Text("Sign Up",
                    style: TextStyle(
                        color: Color(0xFF5D9CFF),
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showError(String m) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating));

  void _showSuccess(String m) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating));

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}