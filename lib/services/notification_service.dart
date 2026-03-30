import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzData;
import 'package:flutter_timezone/flutter_timezone.dart';

import '../models/medicine_model.dart';

//import '../models/medicine_model.dart';
//bp
class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  // setup permissions, timezone, and plugin
  static Future<void> init() async {
    await _setupTimezone(); //needed for correct timing

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    final darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      InitializationSettings(android: androidSettings, iOS: darwinSettings),
      onDidReceiveNotificationResponse: _onTap, //handle click
      onDidReceiveBackgroundNotificationResponse: _onBackgroundTap, //bp
    );

    // bp: android-specific permissions
    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.requestNotificationsPermission();
      await android.requestExactAlarmsPermission();
    }
  }
  static Future<void> initWithSound(String soundId) async => init();
  // schedule multiple reminders for each intake
   static Future<void> scheduleMedicineNotifications({
    required int notificationBaseId,
    required String medicineName,
    required List<IntakeSlot> intakes,
  }) async {
    final details = await _buildDetails(); //bp

    for (int i = 0; i < intakes.length; i++) {
      final intake = intakes[i];

      await _plugin.zonedSchedule(
        notificationBaseId + i, // unique id
        '💊 Time for $medicineName',
        '${intake.label}: Take ${intake.dose} ${intake.dose == 1 ? "dose" : "doses"}',
        _nextOccurrence(intake.time.hour, intake.time.minute), // bp
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // bp:repeat daily
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }


  //daily noti
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

    await _plugin.zonedSchedule(
      notifId,
      title,
      body,
      _nextOccurrence(time.hour, time.minute), //bp
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }


  //one time noti
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

    // bp: avoid past scheduling
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


  // bp:cancel multiple noti
  static Future<void> cancelMedicineNotifications({
    required int notificationBaseId,
    required int intakeCount,
  }) async {
    for (int i = 0; i < intakeCount; i++) {
      await _plugin.cancel(notificationBaseId + i);
    }
  }


  // BP:cancel generic notify
  static Future<void> cancelTrackingNotifications({
    required int baseId,
    required int count,
  }) async {
    for (int i = 0; i < count; i++) {
      await _plugin.cancel(baseId + i);
    }
  }


  // bp:convert F docId → int ID
  static int idFromDocId(String docId) =>
      docId.hashCode.abs() % 100000;


  // BP: Timezone setup-global scheduling
  static Future<void> _setupTimezone() async {
    tzData.initializeTimeZones();
    final info = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(info.identifier));
  }


 //save sound
  static Future<String> _getSavedSound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('notification_sound') ?? 'notification';
  }


  // bp:noti design like sound,priority,vibration
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


  // bp:calc next valid time
  static tz.TZDateTime _nextOccurrence(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);

    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }


  //bp:noti tap
  static void _onTap(NotificationResponse r) =>
      debugPrint('Notification tapped: ${r.payload}');


  //bg tap
  @pragma('vm:entry-point')
  static void _onBackgroundTap(NotificationResponse r) =>
      debugPrint('Background tap: ${r.payload}');
}