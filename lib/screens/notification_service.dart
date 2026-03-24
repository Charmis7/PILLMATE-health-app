

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // PACKAGE: flutter_local_notifications
import 'package:shared_preferences/shared_preferences.dart';                   // PACKAGE: shared_preferences — local device storage
import 'package:timezone/timezone.dart' as tz;                                 // PACKAGE: timezone
import 'package:timezone/data/latest.dart' as tzData;                          // PACKAGE: timezone data
import 'model/medicine_model.dart';

class NotificationService {

  // flutter_local_notifications: the main plugin object — one instance for the whole app
  static final _plugin = FlutterLocalNotificationsPlugin(); // LOCAL NOTIFICATIONS: plugin instance

  // ── INIT (called in main.dart before runApp) ──────────────────────────────
  static Future<void> init() async {

    // TIMEZONE PACKAGE: must initialize timezone data before using tz.getLocation()
    tzData.initializeTimeZones(); // TIMEZONE: loads all timezone data into memory

    // TIMEZONE PACKAGE: sets which timezone to use for scheduling
    // Change 'Asia/Kolkata' to your local timezone if needed
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata')); // TIMEZONE: set local timezone

    // LOCAL NOTIFICATIONS: settings for Android — uses the app launcher icon
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher'); // LOCAL NOTIFICATIONS: Android config

    // LOCAL NOTIFICATIONS: settings for iOS — request all 3 permissions upfront
    const iosSettings = DarwinInitializationSettings( // LOCAL NOTIFICATIONS: iOS config
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // LOCAL NOTIFICATIONS: initialize the plugin with platform settings
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings), // LOCAL NOTIFICATIONS: init
    );

    // LOCAL NOTIFICATIONS: Android-specific — request runtime permissions
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>(); // LOCAL NOTIFICATIONS: get Android-specific plugin
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission(); // LOCAL NOTIFICATIONS: request Android notification permission
      await androidPlugin.requestExactAlarmsPermission();   // LOCAL NOTIFICATIONS: request exact alarm permission (needed for precise timing)
    }
  }

  // ── Init with sound (called from notification permission screen) ──────────
  static Future<void> initWithSound(String soundId) async {
    await init(); // reuse the same init — sound is already saved to SharedPreferences
  }

  // ── Read user's chosen sound from device storage ──────────────────────────
  // SHARED PREFERENCES: local key-value storage ON THE DEVICE — not Firebase
  static Future<String> _getSavedSound() async {
    final prefs = await SharedPreferences.getInstance(); // SHARED_PREFERENCES: get instance
    return prefs.getString('notification_sound') ?? 'notification'; // SHARED_PREFERENCES: read a string value
  }

  // ── Build notification appearance + sound ─────────────────────────────────
  static Future<NotificationDetails> _buildDetails({
    String channelId   = 'pillmate_channel',
    String channelName = 'Medicine Reminders',
  }) async {
    final soundId = await _getSavedSound();

    return NotificationDetails(
      // LOCAL NOTIFICATIONS: Android notification config
      android: AndroidNotificationDetails(
        '${channelId}_$soundId', // channelId includes soundId because Android caches sound per channel
        channelName,
        channelDescription: 'PillMate reminders',
        importance     : Importance.max, // LOCAL NOTIFICATIONS: show as heads-up notification
        priority       : Priority.high,
        icon           : '@mipmap/ic_launcher',
        playSound      : true,
        enableVibration: true,
        sound: RawResourceAndroidNotificationSound(soundId), // LOCAL NOTIFICATIONS: play custom sound file from res/raw/
      ),
      // LOCAL NOTIFICATIONS: iOS notification config
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  // ── Schedule medicine notifications ──────────────────────────────────────
  // Called after saving a medicine — schedules one daily alarm per IntakeSlot
  static Future<void> scheduleMedicineNotifications({
    required int              notificationBaseId, // unique int derived from Firestore doc ID
    required String           medicineName,
    required List<IntakeSlot> intakes,
  }) async {
    final details = await _buildDetails();

    for (int i = 0; i < intakes.length; i++) {
      final intake    = intakes[i];
      final notifId   = notificationBaseId + i; // each intake gets its own unique notification ID
      final scheduled = _nextOccurrence(intake.time.hour, intake.time.minute);

      // LOCAL NOTIFICATIONS: zonedSchedule = schedule at a specific timezone-aware time
      await _plugin.zonedSchedule(
        notifId,
        '💊 Time for $medicineName',
        '${intake.label}: Take ${intake.dose} ${intake.dose == 1 ? "dose" : "doses"}',
        scheduled,
        details,
        androidScheduleMode            : AndroidScheduleMode.exactAllowWhileIdle, // LOCAL NOTIFICATIONS: fire even in deep sleep
        matchDateTimeComponents        : DateTimeComponents.time,                  // LOCAL NOTIFICATIONS: repeat DAILY at same time
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,                   // LOCAL NOTIFICATIONS: iOS time interpretation
      );
    }
  }

  // ── Schedule tracker notification (DAILY REPEAT) ──────────────────────────
  // Used by old step_2.2 and step_3.2 — fires every day at the same time
  static Future<void> scheduleTrackingNotification({
    required int       notifId,
    required String    title,
    required String    body,
    required TimeOfDay time,
  }) async {
    final details   = await _buildDetails(
      channelId  : 'pillmate_tracking',
      channelName: 'Health Tracking',
    );
    final scheduled = _nextOccurrence(time.hour, time.minute);

    // LOCAL NOTIFICATIONS: same zonedSchedule — same daily repeat pattern
    await _plugin.zonedSchedule(
      notifId, title, body, scheduled, details,
      androidScheduleMode            : AndroidScheduleMode.exactAllowWhileIdle, // LOCAL NOTIFICATIONS
      matchDateTimeComponents        : DateTimeComponents.time,                  // LOCAL NOTIFICATIONS: daily repeat
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ── Schedule notification ONCE at exact date + time ──────────────────────
  // Used by: step_2.2_screen and step_3.2_screen (new version with calendar picker)
  //
  // DIFFERENCE from scheduleTrackingNotification:
  //   scheduleTrackingNotification → fires EVERY DAY at same time (daily repeat)
  //   scheduleOnce                 → fires ONE TIME at a specific date + time
  static Future<void> scheduleOnce({
    required int      notifId,
    required String   title,
    required String   body,
    required DateTime dateTime,
  }) async {
    final details = await _buildDetails(
      channelId  : 'pillmate_tracking',
      channelName: 'Health Tracking',
    );

    // TIMEZONE PACKAGE: convert plain DateTime → timezone-aware TZDateTime
    final scheduledTime = tz.TZDateTime(
      tz.local,
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
    );

    // Only schedule if the picked time is still in the future
    // No point scheduling a notification for a time that already passed
    if (scheduledTime.isAfter(tz.TZDateTime.now(tz.local))) {
      await _plugin.zonedSchedule(
        notifId,
        title,
        body,
        scheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // NO matchDateTimeComponents = fires ONCE only, does NOT repeat daily
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  // ── Cancel medicine notifications ─────────────────────────────────────────
  // MUST be called before deleteMedicine() so the alarm also stops
  static Future<void> cancelMedicineNotifications({
    required int notificationBaseId,
    required int intakeCount,
  }) async {
    for (int i = 0; i < intakeCount; i++) {
      await _plugin.cancel(notificationBaseId + i); // LOCAL NOTIFICATIONS: cancel by ID
    }
  }

  // ── Cancel tracker notifications ──────────────────────────────────────────
  static Future<void> cancelTrackingNotifications({
    required int baseId,
    required int count,
  }) async {
    for (int i = 0; i < count; i++) {
      await _plugin.cancel(baseId + i); // LOCAL NOTIFICATIONS: cancel by ID
    }
  }

  // ── Test notification (fires in 5 seconds) ────────────────────────────────
  static Future<void> sendTestNotification() async {
    final details       = await _buildDetails();
    // TIMEZONE PACKAGE: TZDateTime.now() = current time in the set timezone
    final scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)); // TIMEZONE: schedule 5s from now

    await _plugin.zonedSchedule(
      9999, '🔔 PillMate Test', 'Your chosen sound is working!',
      scheduledTime, details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ── Helper: next daily occurrence of hour:minute ──────────────────────────
  // TIMEZONE PACKAGE: TZDateTime is timezone-aware DateTime
  static tz.TZDateTime _nextOccurrence(int hour, int minute) {
    final now       = tz.TZDateTime.now(tz.local);                                         // TIMEZONE: current time in local tz
    var   scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute); // TIMEZONE: today at hour:minute
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1)); // time already passed today → schedule for tomorrow
    }
    return scheduled;
  }

  // ── Convert Firestore doc ID string → consistent int for notification ID ──
  // REASON: notifications need an int ID, Firestore gives us a string ID
  static int idFromDocId(String docId) => docId.hashCode.abs() % 100000;
}