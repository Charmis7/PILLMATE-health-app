import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../other/homepage_screen.dart';
import '../other/onboarding_screen.dart';
//import '../other/splash_screen.dart';


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        /*load state → show splash
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MySplashScreen();
        }*/

         //Logged in
        if (snapshot.hasData) {
          return const HomePageScreen();
        }//Not logged in
        return const OnboardingScreen();
      },
    );
  }
}