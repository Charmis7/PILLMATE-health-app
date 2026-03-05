
import 'package:flutter/material.dart';
import 'package:pillmate_college/screens/routine_screen.dart';

class AsNeededScreen extends StatefulWidget {
  final String medicineName;
  final String unit;

  const AsNeededScreen({super.key, required this.medicineName, required this.unit});

  @override
  State<AsNeededScreen> createState() => _AsNeededScreenState();
}

class _AsNeededScreenState extends State<AsNeededScreen> {
  bool isToggled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        children: [
          const SizedBox(height: 60),
          Center(
            child: Image.asset('assets/images/img_8.png', height: 50),
          ),
          const SizedBox(height: 30),
          Text(
            "Stock: ${widget.medicineName}",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "We'll notify you before your medicine runs out.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Remind me", style: TextStyle(fontSize: 16)),
                    Switch(
                      value: isToggled,
                      onChanged: (newValue) => setState(() => isToggled = newValue),
                    ),
                  ],
                ),
                const Divider(),
                const Align(alignment: Alignment.centerLeft, child: Text("Current Inventory")),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: "30", suffixText: widget.unit),
                ),
                const SizedBox(height: 20),
                const Align(alignment: Alignment.centerLeft, child: Text("Remind me when low:")),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: "5", suffixText: widget.unit),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const RoutineSetupScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Finish Setup", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}