import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pillmate_college/screens/profile_screen.dart';

class NotificationPermissionUIScreen extends StatelessWidget {
  NotificationPermissionUIScreen({super.key});

  final FlutterLocalNotificationsPlugin notifications =
  FlutterLocalNotificationsPlugin();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            Image.asset('assets/images/img_11.png', height: 250),
            const SizedBox(height: 40),

            const Text(
              "Never miss a dose",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            const Text(
              "Enable notifications so we can remind you to take your medicine on time.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  // Setup notifications
                  await notifications.initialize(
                    const InitializationSettings(
                      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
                      iOS: DarwinInitializationSettings(),
                    ),
                  );

                  // Go to profile
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4C8CFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Allow Notifications",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              child: const Text(
                "Maybe later",
                style: TextStyle(color: Color(0xFF4C8CFF)),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}