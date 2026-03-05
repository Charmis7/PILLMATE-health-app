import 'package:flutter/material.dart';

class Step_3_2 extends StatefulWidget {
  final String title;
  const Step_3_2({super.key, required this.title});

  @override
  State<Step_3_2> createState() => _Step_3_2State();
}

class _Step_3_2State extends State<Step_3_2> {
  // 1. DATA STORAGE
  String frequency = "Once daily";
  List<TimeOfDay> entryTimes = [const TimeOfDay(hour: 8, minute: 0)];

  // 2. CLOCK LOGIC
  Future<void> _selectTime(int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: entryTimes[index],
    );
    if (picked != null) {
      setState(() {
        entryTimes[index] = picked;
      });
    }
  }

  // 3. EDIT FREQUENCY DIALOG
  void _editFrequency() {
    TextEditingController controller = TextEditingController(text: frequency);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set Frequency", style: TextStyle(color: Colors.black)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(
            hintText: "e.g. Twice daily",
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => frequency = controller.text);
              Navigator.pop(context);
            },
            child: const Text("Save", style: TextStyle(color: Color(0xFF5D9CFF))),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // UPDATED: Background color to your specific Blue
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // TOP ICON
            Center(child: Image.asset("assets/images/img_1.png", height: 220)),
            const SizedBox(height: 20),
            const Text(
              "Set up reminders to regularly log your measurements and track your progress.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black87, fontSize: 16),
            ),
            const SizedBox(height: 30),

            // FREQUENCY CARD (Editable)
            GestureDetector(
              onTap: _editFrequency,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 2)],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Frequency", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
                          Text(frequency, style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                    const Icon(Icons.edit_outlined, color: Colors.black54),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // REMINDER DETAILS HEADER
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Reminder details", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16)),
            ),

            // DYNAMIC LIST OF TIMES
            Expanded(
              child: ListView.builder(
                itemCount: entryTimes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text("Entry ${index + 1}", style: const TextStyle(color: Colors.black)),
                    trailing: TextButton(
                      onPressed: () => _selectTime(index),
                      child: Text("${entryTimes[index].format(context)} ▼",
                          style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500)),
                    ),
                  );
                },
              ),
            ),

            // ADD ENTRY BUTTON
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() => entryTimes.add(const TimeOfDay(hour: 12, minute: 0))),
                icon: const Icon(Icons.add, color: Colors.black),
                label: const Text("Add entry time", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),

            const Divider(color: Colors.black26),
            const SizedBox(height: 20),

            // SAVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // UPDATED: Button color to your specific Blue
                  backgroundColor: const Color(0xFF5D9CFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 2,
                ),
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text("Save", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}