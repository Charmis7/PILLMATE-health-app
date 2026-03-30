import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pillmate_college/screens/auth/auth_wrapper.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PillMateApp());
}

class PillMateApp extends StatelessWidget {
  const PillMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PillMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5D9CFF)),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}