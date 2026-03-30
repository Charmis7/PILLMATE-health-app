import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/wellbeing_service.dart';
import '../other/homepage_screen.dart';
class Step_4 extends StatefulWidget {
  const Step_4({super.key});

  @override
  State<Step_4> createState() => _Step_4State();
}

class _Step_4State extends State<Step_4> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = const TimeOfDay(hour: 6, minute: 0);
  String selectedMood = "";
  final TextEditingController _symptomsController = TextEditingController();
  bool _isSaving = false;

  Future<void> _saveAndNavigate() async {
    // val
    if (selectedMood.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select your mood")),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {

      await WellbeingService.saveEntry(
        WellbeingEntry(
          id: '',
          date: selectedDate,
          time: selectedTime.format(context),
          mood: selectedMood,
          symptoms: _symptomsController.text.trim(),
        ),
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePageScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1EBFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Image.asset("assets/images/img_7.png", height: 200)),
            const Center(
              child: Text("Track your well-being",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 30),

           //date
            const Text("Date:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) setState(() => selectedDate = picked);
              },
              child: Text(
                DateFormat('EEEE, MMM d, y').format(selectedDate),
                style: const TextStyle(fontSize: 16, color: Colors.blueAccent),
              ),
            ),
            const SizedBox(height: 20),

            //time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Time", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                GestureDetector(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) setState(() => selectedTime = picked);
                  },
                  child: Text("${selectedTime.format(context)} ▼",
                      style: const TextStyle(fontSize: 18, color: Colors.blueAccent)),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // moodd
            const Text("How's your mood?",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ["😄", "🙂", "😔", "😢"].map((emoji) {
                final isSelected = selectedMood == emoji;
                return GestureDetector(
                  onTap: () => setState(() => selectedMood = emoji),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: isSelected ? Colors.blue : Colors.transparent),
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 40)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            // symp
            const Text("Add your symptoms",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: _symptomsController,
              decoration: const InputDecoration(
                hintText: "Enter here...",
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
              ),
            ),
            const SizedBox(height: 50),


            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: _isSaving ? null : _saveAndNavigate,
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("SAVE",
                    style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }
}