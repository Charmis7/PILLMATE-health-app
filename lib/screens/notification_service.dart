import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzData;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'model/medicine_model.dart';

class NotificationService {
  // Static plugin instance for the whole app
  static final _plugin = FlutterLocalNotificationsPlugin();

  // ── INIT (called in main.dart before runApp) ──────────────────────────────
  static Future<void> init() async {
    // 1. Initialize Timezones
    await _configureLocalTimeZone();

    // 2. Android Settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. iOS/Darwin Settings (FIXED: Changed from IOSInitializationSettings)
    final darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // 4. Combine Platform Settings
    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    // 5. Initialize Plugin with Tap Callbacks
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundTap,
    );

    // 6. Request Android Permissions
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }
  }

  // Configure Local Timezone dynamically
  static Future<void> _configureLocalTimeZone() async {
    tzData.initializeTimeZones();
    final TimezoneInfo timeZoneInfo = await FlutterTimezone.getLocalTimezone();
// Access the .identifier property which IS a String
    tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));

  }

  // Foreground tap handler
  static void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped (foreground): payload=${response.payload}');
  }

  // Background/Terminated tap handler
  @pragma('vm:entry-point')
  static void _onBackgroundTap(NotificationResponse response) {
    debugPrint('Notification tapped (background): payload=${response.payload}');
  }

  static Future<void> initWithSound(String soundId) async {
    await init();
  }

  static Future<String> _getSavedSound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('notification_sound') ?? 'notification';
  }

  // ── Build notification appearance + sound ─────────────────────────────────
  static Future<NotificationDetails> _buildDetails({
    String channelId = 'pillmate_channel',
    String channelName = 'Medicine Reminders',
  }) async {
    final soundId = await _getSavedSound();

    return NotificationDetails(
      android: AndroidNotificationDetails(
        '${channelId}_$soundId',
        channelName,
        channelDescription: 'PillMate reminders',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
        sound: RawResourceAndroidNotificationSound(soundId),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  // ── Schedule medicine notifications ──────────────────────────────────────
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
    }
  }

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
      notifId, title, body, scheduled, details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> scheduleOnce({
    required int notifId,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    final details = await _buildDetails(
      channelId: 'pillmate_tracking',
      channelName: 'Health Tracking',
    );

    final scheduledTime = tz.TZDateTime(
      tz.local,
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
    );

    if (scheduledTime.isAfter(tz.TZDateTime.now(tz.local))) {
      await _plugin.zonedSchedule(
        notifId,
        title,
        body,
        scheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

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

  static Future<void> sendTestNotification() async {
    final details = await _buildDetails();
    final scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));

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
  }

  static tz.TZDateTime _nextOccurrence(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static int idFromDocId(String docId) => docId.hashCode.abs() % 100000;
}