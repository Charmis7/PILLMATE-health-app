import 'package:flutter/material.dart';
import 'package:pillmate_college/screens/card_3/step_3.2_screen.dart';


class Step_3_1 extends StatelessWidget {
  const Step_3_1({super.key});

  // need to add more
  final List<String> measurements = const [
    "Brushing teeth",
    "Eating",
    "Stretching",
    "Walking",
    "Water intake",
    "Family time",
    "Cycling",
    "Reading",
    "Sugar intake",
    "Sleeping",
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
        backgroundColor: Colors.orange.shade50,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //search bar
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
              "Popular activities",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),

          //list
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Step_3_2(title: measurements[index]),
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