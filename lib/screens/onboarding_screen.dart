import 'package:flutter/material.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/images/bg1.png', fit: BoxFit.cover)),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/img.png', height: 110),
                    const SizedBox(width: 12),
                    const Text('Pill', style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Color(0xFF007BFF))),
                    const Text('Mate', style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Color(0xFF28A745))),
                  ],
                ),
              ],
            ),
          ),
          Align(
            alignment: const Alignment(-0.8, 0.1),
            child: Text('Take Control Of Your Med', style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold)),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                  child: const Text('GET STARTED', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D8CFF))),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}