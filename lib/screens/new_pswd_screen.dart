import 'package:flutter/material.dart';
import '../widget/reusable_widgets.dart';
import 'login_screen.dart';

class CreatePasswordScreen extends StatelessWidget {
  const CreatePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        children: [
          const SizedBox(height: 80),
          Image.asset('assets/images/img_10.png', height: 200),
          const SizedBox(height: 30),
          const Text("Create New Password", textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          const Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _passwordField("Enter Password"),
          const SizedBox(height: 20),
          const Text("Confirm Password", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _passwordField("Enter Confirm Password"),
          const SizedBox(height: 40),
          PrimaryButton(text: "Reset Password", onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()))),
        ],
      ),
    );
  }

  Widget _passwordField(String hint) {
    return TextField(
        obscureText: true,
        decoration: InputDecoration(
            hintText: hint, filled: true, fillColor: Colors.white, suffixIcon: const Icon(Icons.visibility_off_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))));
  }
}