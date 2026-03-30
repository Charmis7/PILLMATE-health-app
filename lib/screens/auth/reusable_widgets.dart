import 'package:flutter/material.dart';


class AuthBackground extends StatelessWidget {
  final Widget child;
  final String imagePath;
  final Color backgroundColor;

  const AuthBackground({
    super.key,
    required this.child,
    required this.imagePath,
    this.backgroundColor = const Color(0xFFE1F0FC),
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: screenHeight * 0.35,
            child: Image.asset(imagePath, fit: BoxFit.cover),
          ),

          Column(
            children: [
              SizedBox(height: screenHeight * 0.28),

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: child, // Your content goes here
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//gradiant color
class ScreenWrapper extends StatelessWidget {
  final Widget child; // content
  

  const ScreenWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8EACCD),
              Color(0xFFD1E0F7),
              Color(0xFFF5F9FF),
            ],
          ),
        ),
        child: child,
      ),
    );
  }
}

//button
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4C8CFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}