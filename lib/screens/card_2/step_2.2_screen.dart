import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/tracker_model.dart';
import '../../services/notification_service.dart';
import '../../services/tracker_service.dart';
import '../other/homepage_screen.dart';
class Step_2_2 extends StatefulWidget {
  final String title;
  const Step_2_2({super.key, required this.title});

  @override
  State<Step_2_2> createState() => _Step_2_2State();
}

class _Step_2_2State extends State<Step_2_2> {


  DateTime  selectedDate = DateTime.now();
  TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);
  bool      _isSaving    = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context    : context,
      initialDate: selectedDate,
      firstDate  : DateTime.now(),
      lastDate   : DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context    : context,
      initialTime: selectedTime,
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  Future<void> _saveAndNavigate() async {//save noti
    setState(() => _isSaving = true);
    try {


      final frequencyText =
          '${DateFormat('MMM d').format(selectedDate)} at ${selectedTime.format(context)}';


      final entry = TrackerEntry(
        id       : '',
        title    : widget.title,
        type     : 'measurement',
        frequency: frequencyText,
        times    : [selectedTime],
      );


      final docId = await TrackerService.saveTracker(entry);


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


              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [


                      _buildRow(
                        label: 'Date',
                        value: DateFormat('yMMMd').format(selectedDate),
                        onTap: _pickDate,
                      ),
                      const Divider(),


                      _sectionTitle('Reminder'),


                      _buildRow(
                        label: 'Time',
                        value: selectedTime.format(context),
                        onTap: _pickTime,
                      ),

                    ],
                  ),
                ),
              ),

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