import 'package:flutter/material.dart';
import 'package:pillmate_college/screens/step_1.1_screen.dart';
import 'package:pillmate_college/screens/homepage_screen.dart';
import 'package:pillmate_college/screens/step_2.1_screen.dart';
import 'package:pillmate_college/screens/step_3.1_screen.dart';
import 'package:pillmate_college/screens/step_4_screen.dart';

class RoutineSetupScreen extends StatelessWidget {
  const RoutineSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              const Text(
                "Let's set up your routine",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B2B2B),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: _categoryCard(
                        context: context,
                        title: "Medicine",
                        sub: "Add medication and track intake",
                        imgPath: "assets/images/img_3.png",
                        nextScreen: const Step_1(),
                        colorStart: Colors.blue.shade100,
                        colorEnd: Colors.blue.shade50,
                      ),
                    ),
                    Expanded(
                      child: _categoryCard(
                        context: context,
                        title: "Measurements",
                        sub: "Log health data and measurements",
                        imgPath: "assets/images/img_4.png",
                        nextScreen: Step_2_1(),
                        colorStart: Colors.green.shade100,
                        colorEnd: Colors.green.shade50,
                      ),
                    ),
                    Expanded(
                      child: _categoryCard(
                        context: context,
                        title: "Activities",
                        sub: "Set up reminder for daily habits",
                        imgPath: "assets/images/img_5.png",
                        nextScreen: const Step_3_1(),
                        colorStart: Colors.orange.shade100,
                        colorEnd: Colors.orange.shade50,
                      ),
                    ),
                    Expanded(
                      child: _categoryCard(
                        context: context,
                        title: "Mood & Symptoms",
                        sub: "Log your mood and unusual symptoms",
                        imgPath: "assets/images/img_6.png",
                        nextScreen: const Step_4(),
                        colorStart: Colors.purple.shade100,
                        colorEnd: Colors.purple.shade50,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 6,
                  ),
                  onPressed: () {
                    // Directly navigate to HomePageScreen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HomePageScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "All done!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryCard({
    required BuildContext context,
    required String title,
    required String sub,
    required String imgPath,
    required Widget nextScreen,
    required Color colorStart,
    required Color colorEnd,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => nextScreen));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [colorStart, colorEnd]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Image.asset(imgPath, width: 60, height: 60),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          subtitle: Text(
            sub,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black87, size: 25),
        ),
      ),
    );
  }
}