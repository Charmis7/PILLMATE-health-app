import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';


class MySplashScreen extends StatelessWidget {
  const MySplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB3C8F0),
              Color(0xFFE1EBFC),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Lottie.asset('assets/animation_123.json'),
        ),
      ),
    );
  }
}
// we can do this too but
/*
class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {

  @override
  void initState() {//runs once when screen loads
    super.initState();
    _checkLoginAndNavigate();
  }
  Future<void> _checkLoginAndNavigate() async {

    await Future.delayed(const Duration(seconds: 3));


    final user = await FirebaseAuth.instance.authStateChanges().first;//get current login state


    if (mounted) {//prevent crash if w is disposed
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => user != null
              ? const HomePageScreen()    // logged in = home
              : const OnboardingScreen(), // not logged in = onboarding
        ),
      );
    }
  }*/