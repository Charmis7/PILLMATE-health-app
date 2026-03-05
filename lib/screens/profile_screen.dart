import 'package:flutter/material.dart';
import 'package:pillmate_college/screens/routine_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row( mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Pill',
                style: TextStyle(
                  fontSize: 45,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFF007BFF),
                ),
              ),
              Text(
                'Mate',
                style: TextStyle(
                  fontSize: 45,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFF28A745),
                ),
              ),
            ],
          ),
          // Illustration Image
          Image.asset('assets/images/img_1.png', height:350),
          const SizedBox(height: 5),

          const Text(
            "Set up your healthy routine",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          const Text(
            "Helps you manage medication, hydration, and daily health routines with timely reminders.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 50),

          // Navigation Button
          SizedBox(
            width: 350,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D9CFF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                // This moves to Home and deletes the Login/Signup history
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const RoutineSetupScreen ()),
                      (route) => false, // This 'false' means "remove all previous screens"
                );
              },
              child: const Text("I'm ready", style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ),
        ],
      ),

    );
  }
}