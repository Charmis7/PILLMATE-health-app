import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pillmate_college/screens/onboarding_screen.dart';
import 'package:pillmate_college/screens/homepage_screen.dart';
//animation got it from Demitry Naumov-lottiefiles
class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {

  @override
  void initState() {
    super.initState();
    _checkLoginAndNavigate();
  }
  Future<void> _checkLoginAndNavigate() async {

    await Future.delayed(const Duration(seconds: 3));


    final user = await FirebaseAuth.instance.authStateChanges().first;//get current login state


    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => user != null
              ? const HomePageScreen()    // logged in = home
              : const OnboardingScreen(), // not logged in = onboarding
        ),
      );
    }
  }//all are boiler plate code

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB3C8F0),
              Color(0xFFE1EBFC),
              Colors.white,
            ],
          ),
        ),


        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 300,
              child: Lottie.asset(
                'assets/animation_123.json',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Pill',
                    style: TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF007BFF))),
                const Text('Mate',
                    style: TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF28A745))),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              "Right Pill, Right Time",
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.black45,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}