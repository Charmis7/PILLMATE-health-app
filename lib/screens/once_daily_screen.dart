import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pillmate_college/screens/routine_screen.dart';

class OnceDailyScreen extends StatefulWidget {
  final String medicineName;
  final String unit;

  const OnceDailyScreen({
    super.key,
    required this.medicineName,
    required this.unit,
  });

  @override
  State<OnceDailyScreen> createState() => _OnceDailyScreenState();
}

class _OnceDailyScreenState extends State<OnceDailyScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay intakeTime = const TimeOfDay(hour: 6, minute: 0);
  int dose = 1;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: intakeTime,
    );
    if (picked != null) setState(() => intakeTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1EBFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Image.asset('assets/images/img_2.png', height: 100),
              const SizedBox(height: 20),

              Text(
                "Reminder for ${widget.medicineName}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4C8CFF),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "When would you like to be reminded?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildRow(
                        "Start date",
                        DateFormat('yMMMd').format(selectedDate),
                        _pickDate,
                      ),
                      const Divider(),

                      _sectionTitle("Intake"),
                      _buildRow("Time", intakeTime.format(context), _pickTime),
                      _doseRow(dose, (val) => setState(() => dose = val)),
                    ],
                  ),
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D9CFF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RoutineSetupScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Set Reminder",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
          fontSize: 14,
        ),
      ),
    ),
  );

  Widget _buildRow(String label, String value, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(color: Colors.blue)),
          const Icon(Icons.arrow_drop_down, color: Colors.blue),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _doseRow(int dose, Function(int) onChanged) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Text("Dose", style: TextStyle(fontWeight: FontWeight.bold)),
      Row(
        children: [
          IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.blue),
              onPressed: dose > 1 ? () => onChanged(dose - 1) : null),
          Text("$dose ${widget.unit}", style: const TextStyle(color: Colors.blue)),
          IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
              onPressed: () => onChanged(dose + 1)),
        ],
      ),
    ],
  );
}