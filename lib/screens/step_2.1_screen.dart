import 'package:flutter/material.dart';
import 'package:pillmate_college/screens/step_2.2_screen.dart';


class Step_2_1 extends StatelessWidget {
  const Step_2_1({super.key});

  // Your list of data from the screenshot
  final List<String> measurements = const [
    "Blood pressure",
    "Resting heart rate",
    "Weight",
    "Blood sugar (before the meal)",
    "Blood sugar (after the meal)",
    "Temperature",
    "Alcohol level",
    "Apheresis",
    "Body fat percentage",
    "Ferritin",
    "LDL cholesterol",
    "Weight",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Search", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.green.shade50,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              "Popular measurements",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),

          // 2. SCROLLABLE LIST
          Expanded(
            child: ListView.builder(
              itemCount: measurements.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    measurements[index],
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  // Inside ListView.builder
                  onTap: () {
                    // Navigate to your specific file Step_2_2
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Step_2_2(title: measurements[index]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Simple placeholder for the "Different Page"
class DetailScreen extends StatelessWidget {
  final String title;
  const DetailScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text("You selected: $title")),
    );
  }
}