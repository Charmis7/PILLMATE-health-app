
import 'package:flutter/material.dart';
import 'package:pillmate_college/screens/auth/reusable_widgets.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final _formKey= GlobalKey<FormState>();
  final _nameController= TextEditingController();
  final _emailController= TextEditingController();
  final _passwordController= TextEditingController();
  final _confirmPasswordController= TextEditingController();
  final _authService= AuthService();//auth
  bool _hidePassword        = true;
  bool _hideConfirmPassword = true;
  bool _isLoading           = false;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final error = await _authService.signUp(
      name    : _nameController.text.trim(),
      email   : _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (error == null) {
      _showSuccess('Account created successfully!');
      if (mounted) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    } else {
      _showError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      imagePath: 'assets/images/topimg.png',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Text('Create your Account',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),

            // Name
            TextFormField(
              controller: _nameController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(labelText: 'Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
              validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 15),

            // Email
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(labelText: 'Email', hintText: 'example@gmail.com',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter valid email';
                return null;
              },
            ),
            const SizedBox(height: 15),

            // Password
            TextFormField(
              controller: _passwordController,
              obscureText: _hidePassword,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(_hidePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _hidePassword = !_hidePassword),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password required';
                if (v.length < 8) return 'Minimum 8 characters';
                return null;
              },
            ),
            const SizedBox(height: 15),

            // Confirm password
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _hideConfirmPassword,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                suffixIcon: IconButton(
                  icon: Icon(_hideConfirmPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _hideConfirmPassword = !_hideConfirmPassword),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Confirm your password';
                if (v != _passwordController.text) return 'Passwords do not match';
                return null;
              },
            ),
            const SizedBox(height: 30),

            _isLoading
                ? const CircularProgressIndicator()
                : PrimaryButton(text: 'Sign Up', onPressed: _signUp),
          ],
        ),
      ),
    );
  }

  void _showError(String m)   => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), backgroundColor: Colors.red));
  void _showSuccess(String m) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), backgroundColor: Colors.green));

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}