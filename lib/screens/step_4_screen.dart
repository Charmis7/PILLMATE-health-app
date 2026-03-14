import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Step_4 extends StatefulWidget {
  const Step_4({super.key});

  @override
  State<Step_4> createState() => _Step_4State();
}

class _Step_4State extends State<Step_4> {
  // We create simple variables to hold the information
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = const TimeOfDay(hour: 6, minute: 0);
  String selectedMood = ""; // We will just store the emoji string here
  final TextEditingController _symptomsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1EBFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- IMAGE ---
            Center(
              child: Image.asset("assets/images/img_7.png", height: 200),
            ),

            // --- TITLE ---
            const Center(
              child: Text(
                "Track your well-being",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),

            // --- DATE SECTION ---
            const Text("Date:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            GestureDetector(
              onTap: () async {
                // This is the simplest way to show a date picker
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
              child: Text(
                DateFormat('EEEE, MMM d, y').format(selectedDate),
                style: const TextStyle(fontSize: 16, color: Colors.blueAccent),
              ),
            ),

            const SizedBox(height: 20),

            // --- TIME SECTION ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Time", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                GestureDetector(
                  onTap: () async {
                    // Simple time picker
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        selectedTime = pickedTime;
                      });
                    }
                  },
                  child: Text(
                    "${selectedTime.format(context)} ▼",
                    style: const TextStyle(fontSize: 18, color: Colors.blueAccent),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // --- MOOD SECTION (NO LOOPS, JUST MANUAL) ---
            const Text("How’s your mood?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // EMOJI 1
                GestureDetector(
                  onTap: () {
                    setState(() { selectedMood = "😄"; });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selectedMood == "😄" ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: selectedMood == "😄" ? Colors.blue : Colors.transparent),
                    ),
                    child: const Text("😄", style: TextStyle(fontSize: 40)),
                  ),
                ),
                // EMOJI 2
                GestureDetector(
                  onTap: () {
                    setState(() { selectedMood = "🙂"; });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selectedMood == "🙂" ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: selectedMood == "🙂" ? Colors.blue : Colors.transparent),
                    ),
                    child: const Text("🙂", style: TextStyle(fontSize: 40)),
                  ),
                ),
                // EMOJI 3
                GestureDetector(
                  onTap: () {
                    setState(() { selectedMood = "😔"; });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selectedMood == "😔" ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: selectedMood == "😔" ? Colors.blue : Colors.transparent),
                    ),
                    child: const Text("😔", style: TextStyle(fontSize: 40)),
                  ),
                ),
                // EMOJI 4
                GestureDetector(
                  onTap: () {
                    setState(() { selectedMood = "😢"; });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selectedMood == "😢" ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: selectedMood == "😢" ? Colors.blue : Colors.transparent),
                    ),
                    child: const Text("😢", style: TextStyle(fontSize: 40)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // --- SYMPTOMS INPUT ---
            const Text("Add your symptoms", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: _symptomsController,
              decoration: const InputDecoration(
                hintText: "Enter here...",
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
              ),
            ),

            const SizedBox(height: 50),

            // --- SAVE BUTTON ---
            Container(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                onPressed: () {
                  // We just print the values to see if they work
                  print("Saved Mood: $selectedMood");
                  print("Saved Symptoms: ${_symptomsController.text}");

                  // Go back to the previous screen
                  Navigator.pop(context);
                },
                child: const Text(
                  "SAVE",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}