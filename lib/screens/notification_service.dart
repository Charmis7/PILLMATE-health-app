import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;
import 'medicine_model.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  // ── Standard init (called in main.dart) ────────────────────────────────
  static Future<void> init() async {
    tzData.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }
  }

  // ── Init with a specific sound (called from permission screen) ──────────
  static Future<void> initWithSound(String soundId) async {
    await init(); // sets up timezone + permissions
    // soundId is saved to prefs by the permission screen
    // it will be read by _buildDetails() on every notification call
    debugPrint('✅ Notification sound set to: $soundId');
  }

  // ── Read saved sound from prefs ─────────────────────────────────────────
  static Future<String> _getSavedSound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('notification_sound') ?? 'sound_1';
  }

  // ── Build notification details with user's chosen sound ─────────────────
  static Future<NotificationDetails> _buildDetails({
    String channelId = 'pillmate_channel',
    String channelName = 'Medicine Reminders',
  }) async {
    final soundId = await _getSavedSound();

    return NotificationDetails(
      android: AndroidNotificationDetails(
        // Include soundId in channelId so each sound gets its own channel
        // Android channels cache sound — different channel = different sound
        '${channelId}_$soundId',
        channelName,
        channelDescription: 'PillMate reminders',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
        sound: RawResourceAndroidNotificationSound(soundId),
        // e.g. RawResourceAndroidNotificationSound('sound_1')
        // File: android/app/src/main/res/raw/sound_1.mp3
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        // For iOS: add sound files to Runner/ in Xcode
        // then set: sound: 'sound_1.mp3'
      ),
    );
  }

  // ── Schedule medicine notifications ────────────────────────────────────
  static Future<void> scheduleMedicineNotifications({
    required int notificationBaseId,
    required String medicineName,
    required List<IntakeSlot> intakes,
  }) async {
    final details = await _buildDetails();

    for (int i = 0; i < intakes.length; i++) {
      final intake = intakes[i];
      final notifId = notificationBaseId + i;
      final scheduled = _nextOccurrence(intake.time.hour, intake.time.minute);

      debugPrint('📅 Scheduling $medicineName at $scheduled (id: $notifId)');

      await _plugin.zonedSchedule(
        notifId,
        '💊 Time for $medicineName',
        '${intake.label}: Take ${intake.dose} ${intake.dose == 1 ? "dose" : "doses"}',
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint('✅ Scheduled: $medicineName | ${intake.time.hour}:${intake.time.minute}');
    }
  }

  // ── Schedule tracking notification ─────────────────────────────────────
  static Future<void> scheduleTrackingNotification({
    required int notifId,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    final details = await _buildDetails(
      channelId: 'pillmate_tracking',
      channelName: 'Health Tracking',
    );
    final scheduled = _nextOccurrence(time.hour, time.minute);

    await _plugin.zonedSchedule(
      notifId,
      title,
      body,
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ── Test notification — fires in 5 seconds ──────────────────────────────
  static Future<void> sendTestNotification() async {
    final details = await _buildDetails();
    final scheduledTime =
    tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));

    await _plugin.zonedSchedule(
      9999,
      '🔔 PillMate Test',
      'Your chosen sound is working!',
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
    debugPrint('✅ Test notification at $scheduledTime');
  }

  // ── Cancel ──────────────────────────────────────────────────────────────
  static Future<void> cancelMedicineNotifications({
    required int notificationBaseId,
    required int intakeCount,
  }) async {
    for (int i = 0; i < intakeCount; i++) {
      await _plugin.cancel(notificationBaseId + i);
    }
  }

  static Future<void> cancelTrackingNotifications({
    required int baseId,
    required int count,
  }) async {
    for (int i = 0; i < count; i++) {
      await _plugin.cancel(baseId + i);
    }
  }

  // ── Helper ──────────────────────────────────────────────────────────────
  static tz.TZDateTime _nextOccurrence(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
    tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static int idFromDocId(String docId) => docId.hashCode.abs() % 100000;
}