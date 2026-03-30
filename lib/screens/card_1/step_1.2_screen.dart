import 'package:flutter/material.dart';
import 'once_daily_screen.dart';
import 'twice_daily_screen.dart';
import 'thrice_daily_screen.dart';
import 'as_needed_screen.dart';

class Step_2 extends StatefulWidget {
  final String medicineName;
  final String unit;
  final String condition; // ← new

  const Step_2({
    super.key,
    required this.medicineName,
    required this.unit,
    required this.condition,
  });

  @override
  State<Step_2> createState() => _Step_2State();
}

class _Step_2State extends State<Step_2> {
  String selectedFrequency = "";

  final List<String> options = [
    "Once a daily",
    "Twice a daily",
    "Three time a daily",
    "As needed",
  ];

  void _navigate(String option) {
    Widget nextScreen;

    if (option == "Once a daily") {
      nextScreen = OnceDailyScreen(
        medicineName: widget.medicineName,
        unit: widget.unit,
        condition: widget.condition,
      );
    } else if (option == "Twice a daily") {
      nextScreen = TwiceDailyScreen(
        medicineName: widget.medicineName,
        unit: widget.unit,
        condition: widget.condition,
      );
    } else if (option == "Three time a daily") {
      nextScreen = ThreeTimesDailyScreen(
        medicineName: widget.medicineName,
        unit: widget.unit,
        condition: widget.condition,
      );
    } else {
      nextScreen = AsNeededScreen(
        medicineName: widget.medicineName,
        unit: widget.unit,
        condition: widget.condition,
      );
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => nextScreen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFD6EAFE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Hero(
                tag: 'app_logo',
                child: Image.asset('assets/images/img_2.png', height: 120),
              ),
              const SizedBox(height: 20),
              const Text(
                "Frequency",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A374D)),
              ),
              const SizedBox(height: 8),
              const Text(
                "How often do you take this medication?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 35),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    String option = options[index];
                    bool isSelected = selectedFrequency == option;

                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedFrequency = option);
                        Future.delayed(
                          const Duration(milliseconds: 200),
                              () => _navigate(option),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white.withOpacity(0.9) : Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF5D9CFF) : Colors.white,
                            width: 1.5,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: const Color(0xFF5D9CFF).withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))]
                              : [],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              option,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? const Color(0xFF5D9CFF) : const Color(0xFF1A374D),
                              ),
                            ),
                            Icon(
                              isSelected ? Icons.check_circle : Icons.arrow_forward_ios_rounded,
                              size: 20,
                              color: isSelected ? const Color(0xFF5D9CFF) : Colors.black26,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}