import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings,
        onDidReceiveNotificationResponse: (details) {});

    // Request notification permission (Android 13+)
    await _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

    _initialized = true;
  }

  Future<void> scheduleDaily(int id, String title, String body, int hour, int minute) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'bro_reminders', 'BRO Reminders',
          channelDescription: 'Daily fitness reminders',
          importance: Importance.high,
          priority: Priority.high,
          color: const Color(0xFF00E5FF),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> showInstant(String title, String body) async {
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'bro_instant', 'BRO Alerts',
          channelDescription: 'Instant fitness alerts',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> cancelReminder(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  // Preset reminders for gym lovers
  Future<void> setupDefaultReminders() async {
    await scheduleDaily(100, '💧 Hydration Check', 'Time to drink some water! Stay hydrated.', 10, 0);
    await scheduleDaily(101, '💧 Hydration Check', "Don't forget to drink water!", 14, 0);
    await scheduleDaily(102, '💧 Hydration Check', 'Evening water reminder. Drink up!', 18, 0);
    await scheduleDaily(103, '🏋️ Workout Reminder', "Time to hit the gym! Let's go BRO!", 7, 0);
    await scheduleDaily(104, '📓 Log Your Meals', "Have you logged today's meals?", 20, 0);
    await scheduleDaily(105, '🌙 Wind Down', 'Get 7-9 hours of sleep for optimal muscle recovery.', 22, 0);
  }
}
