import 'package:flutter/material.dart';
import 'package:pillmate_college/screens/auth/reusable_widgets.dart';
import '../../services/auth_service.dart';
import '../profile/setting_profile_screen.dart';
import 'signup_screen.dart';
import 'forgot_pswd_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _hidePassword = true;
  bool _isLoading = false;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) { _showError("Please enter your email"); return; }
    if (!email.contains("@")) { _showError("Enter a valid email"); return; }
    if (password.isEmpty) { _showError("Enter your password"); return; }
    if (password.length < 6) { _showError("Password must be at least 6 characters"); return; }

    setState(() => _isLoading = true);
    final error = await _authService.login(email: email, password: password);
    setState(() => _isLoading = false);

    if (error == null) {
      _navigateToHome();
    } else {
      _showError(error);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    final error = await _authService.signInWithGoogle();
    setState(() => _isLoading = false);

    if (error == null) {
      _navigateToHome();
    } else {
      _showError(error);
    }
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SettingProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      imagePath: 'assets/images/topimg.png',
      child: Column(
        children: [
          const Text("Welcome Back", textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),

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

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
              child: const Text("Forgot Password?", style: TextStyle(fontSize: 12)),
            ),
          ),

          const SizedBox(height: 20),

          _isLoading
              ? const CircularProgressIndicator()
              : Column(
            children: [
              PrimaryButton(text: "Login", onPressed: _login),
              const SizedBox(height: 15),
              OutlinedButton.icon(
                icon: Image.asset('assets/images/google.png', height: 24),
                label: const Text("Sign in with Google"),
                onPressed: _loginWithGoogle,
              ),
            ],
          ),

          const SizedBox(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account? "),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
                child: const Text("Sign Up", style: TextStyle(color: Color(0xFF5D9CFF), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showError(String m) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}