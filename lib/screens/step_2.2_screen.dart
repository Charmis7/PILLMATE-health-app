import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'homepage_screen.dart';
import 'tracker_model.dart';
import 'tracker_service.dart';
import 'notification_service.dart';

class Step_2_2 extends StatefulWidget {
  final String title;
  const Step_2_2({super.key, required this.title});

  @override
  State<Step_2_2> createState() => _Step_2_2State();
}

class _Step_2_2State extends State<Step_2_2> {

  // One date + one time — same as once_daily_screen
  DateTime  selectedDate = DateTime.now();
  TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);
  bool      _isSaving    = false;

  // ── Open calendar — same as once_daily_screen _pickDate() ──────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context    : context,
      initialDate: selectedDate,
      firstDate  : DateTime.now(),
      lastDate   : DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  // ── Open clock — same as once_daily_screen _pickTime() ─────────────────
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context    : context,
      initialTime: selectedTime,
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  // ── Save to Firestore + schedule notification ───────────────────────────
  Future<void> _saveAndNavigate() async {
    setState(() => _isSaving = true);
    try {

      // Build frequency string to show in bottom_nav_chart
      // e.g. "Jan 15 at 8:00 AM"
      final frequencyText =
          '${DateFormat('MMM d').format(selectedDate)} at ${selectedTime.format(context)}';

      // Build TrackerEntry model
      final entry = TrackerEntry(
        id       : '',
        title    : widget.title,
        type     : 'measurement',
        frequency: frequencyText,
        times    : [selectedTime],
      );

      // FIRESTORE: save tracker, returns auto-generated doc ID
      final docId = await TrackerService.saveTracker(entry);

      // LOCAL NOTIFICATIONS: schedule once at the exact date + time
      final scheduledDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      await NotificationService.scheduleOnce(
        notifId : NotificationService.idFromDocId(docId),
        title   : '📊 ${widget.title}',
        body    : 'Time to log your ${widget.title}',
        dateTime: scheduledDateTime,
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
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // same background color as once_daily_screen
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Image.asset('assets/images/img_1.png', height: 300),
              const SizedBox(height: 20),

              // Title
              Text(
                'Reminder for ${widget.title}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize  : 22,
                    fontWeight: FontWeight.bold,
                    color     : Color(0xFF4C8CFF)),
              ),
              const SizedBox(height: 10),
              const Text(
                'When would you like to be reminded?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // ── Rows — exact same style as once_daily_screen ──────────
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [

                      // Date row
                      _buildRow(
                        label: 'Date',
                        value: DateFormat('yMMMd').format(selectedDate),
                        onTap: _pickDate,
                      ),
                      const Divider(),

                      // Section label
                      _sectionTitle('Reminder'),

                      // Time row
                      _buildRow(
                        label: 'Time',
                        value: selectedTime.format(context),
                        onTap: _pickTime,
                      ),

                    ],
                  ),
                ),
              ),

              // Save button — same as once_daily_screen
              SizedBox(
                width : double.infinity,
                height: 55,
                child : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D9CFF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSaving ? null : _saveAndNavigate,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Set Reminder',
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

  // ── Exact same helper as once_daily_screen ──────────────────────────────
  Widget _sectionTitle(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            color     : Colors.blueGrey,
            fontSize  : 14),
      ),
    ),
  );

  // ── Exact same helper as once_daily_screen ──────────────────────────────
  Widget _buildRow(
      {required String label,
        required String value,
        required VoidCallback onTap}) =>
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value,
                style: const TextStyle(color: Colors.blue, fontSize: 16)),
            const Icon(Icons.arrow_drop_down, color: Colors.blue),
          ],
        ),
        onTap: onTap,
      );
}