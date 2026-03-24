import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pillmate_college/screens/notification_service.dart';
import 'package:pillmate_college/screens/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // init Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // init local notifications
  await NotificationService.init();

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
      home: const MySplashScreen(),
    );
  }
}