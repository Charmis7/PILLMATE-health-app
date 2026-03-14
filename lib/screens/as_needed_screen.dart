import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'homepage_screen.dart';
import 'medicine_model.dart';
import 'medicine_service.dart';

class AsNeededScreen extends StatefulWidget {
  final String medicineName;
  final String unit;
  final String condition;

  const AsNeededScreen({
    super.key,
    required this.medicineName,
    required this.unit,
    required this.condition,
  });

  @override
  State<AsNeededScreen> createState() => _AsNeededScreenState();
}

class _AsNeededScreenState extends State<AsNeededScreen> {
  DateTime selectedDate = DateTime.now();
  int dose = 1;
  bool _isSaving = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context, initialDate: selectedDate,
      firstDate: DateTime.now(), lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _saveAndNavigate() async {
    setState(() => _isSaving = true);
    try {
      final entry = MedicineEntry(
        id: '', name: widget.medicineName, unit: widget.unit,
        condition: widget.condition, frequency: 'asneeded',
        startDate: selectedDate,
        intakes: [IntakeSlot(time: const TimeOfDay(hour: 0, minute: 0), dose: dose, label: 'As Needed')],
      );

      await MedicineService.saveMedicine(entry);
      // No notifications for "as needed"

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePageScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6EAFE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Image.asset('assets/images/img_2.png', height: 100),
              const SizedBox(height: 20),
              Text("${widget.medicineName} — As Needed",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4C8CFF))),
              const SizedBox(height: 10),
              const Text("No reminder — take when required",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 30),
              Expanded(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Start date", style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(DateFormat('yMMMd').format(selectedDate),
                            style: const TextStyle(color: Colors.blue, fontSize: 16)),
                        const Icon(Icons.arrow_drop_down, color: Colors.blue),
                      ]),
                      onTap: _pickDate,
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Dose", style: TextStyle(fontWeight: FontWeight.bold)),
                        Row(children: [
                          IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.blue),
                              onPressed: dose > 1 ? () => setState(() => dose--) : null),
                          Text("$dose ${widget.unit}", style: const TextStyle(color: Colors.blue)),
                          IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
                              onPressed: () => setState(() => dose++)),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D9CFF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSaving ? null : _saveAndNavigate,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save Medicine", style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}