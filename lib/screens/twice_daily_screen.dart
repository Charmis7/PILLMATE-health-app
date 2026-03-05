import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pillmate_college/screens/routine_screen.dart';

class TwiceDailyScreen extends StatefulWidget {
  final String medicineName;
  final String unit;

  const TwiceDailyScreen({
    super.key,
    required this.medicineName,
    required this.unit,
  });

  @override
  State<TwiceDailyScreen> createState() => _TwiceDailyScreenState();
}

class _TwiceDailyScreenState extends State<TwiceDailyScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay firstTime = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay secondTime = const TimeOfDay(hour: 18, minute: 0);

  int firstDose = 1;
  int secondDose = 1;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _pickTime(int intake) async {
    TimeOfDay initial = intake == 1 ? firstTime : secondTime;

    final picked =
    await showTimePicker(context: context, initialTime: initial);

    if (picked != null) {
      setState(() {
        if (intake == 1) {
          firstTime = picked;
        } else {
          secondTime = picked;
        }
      });
    }
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
                "Reminders for ${widget.medicineName}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4C8CFF)),
              ),

              const SizedBox(height: 10),

              const Text(
                "Set your morning and evening schedule",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildRow("Start date",
                          DateFormat('yMMMd').format(selectedDate), _pickDate),
                      const Divider(),

                      _sectionTitle("Morning intake"),
                      _buildRow(
                          "Time", firstTime.format(context), () => _pickTime(1)),
                      _doseRow(firstDose,
                              (val) => setState(() => firstDose = val)),

                      const Divider(),

                      _sectionTitle("Evening intake"),
                      _buildRow("Time", secondTime.format(context),
                              () => _pickTime(2)),
                      _doseRow(secondDose,
                              (val) => setState(() => secondDose = val)),
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
                          builder: (_) => const RoutineSetupScreen()),
                    );
                  },
                  child: const Text(
                    "Set Reminders",
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
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
              fontSize: 14)),
    ),
  );

  Widget _buildRow(String label, String value, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title:
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
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
      const Text("Dose",
          style: TextStyle(fontWeight: FontWeight.bold)),
      Row(
        children: [
          IconButton(
              icon: const Icon(Icons.remove_circle_outline,
                  color: Colors.blue),
              onPressed:
              dose > 1 ? () => onChanged(dose - 1) : null),
          Text("$dose ${widget.unit}",
              style: const TextStyle(color: Colors.blue)),
          IconButton(
              icon: const Icon(Icons.add_circle_outline,
                  color: Colors.blue),
              onPressed: () => onChanged(dose + 1)),
        ],
      ),
    ],
  );
}