import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Skip notifications on web (not supported)
    if (kIsWeb) return;

    // Initialize timezones
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  // Schedule daily reminders
  static Future<void> scheduleMealReminders({
    bool breakfast = true,
    bool lunch = true,
    bool dinner = true,
    bool water = true,
  }) async {
    // Skip notifications on web
    if (kIsWeb) return;

    await _notifications.cancelAll();

    if (breakfast) {
      await _scheduleNotification(
        id: 1,
        title: '🍳 Time for Breakfast!',
        body: 'Log your morning meal to start the day right',
        hour: 8,
        minute: 0,
      );
    }

    if (lunch) {
      await _scheduleNotification(
        id: 2,
        title: '🥗 Lunch Time!',
        body: 'Don\'t forget to log your lunch',
        hour: 12,
        minute: 30,
      );
    }

    if (dinner) {
      await _scheduleNotification(
        id: 3,
        title: '🍽️ Dinner Reminder',
        body: 'Log your dinner to complete the day',
        hour: 19,
        minute: 0,
      );
    }

    if (water) {
      // Water reminders every 2 hours during waking hours
      for (int i = 0; i < 8; i++) {
        await _scheduleNotification(
          id: 10 + i,
          title: '💧 Hydration Check',
          body: 'Time to drink some water!',
          hour: 8 + (i * 2),
          minute: 0,
        );
      }
    }
  }

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'meal_reminders',
            'Meal Reminders',
            channelDescription: 'Reminders for logging meals and water',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      // Silently fail if exact alarms not permitted
      // User needs to grant permission in system settings
      if (kDebugMode) {
        print('Failed to schedule notification: $e');
      }
    }
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // Show immediate notification (for achievements, etc.)
  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    // Skip notifications on web
    if (kIsWeb) return;

    await _notifications.show(
      DateTime.now().millisecond,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'general',
          'General Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}

// Stub for timezone (add timezone package if needed)
class TZDateTime {
  static TZDateTime from(DateTime dateTime, String location) {
    return TZDateTime._(dateTime);
  }

  final DateTime _dateTime;
  TZDateTime._(this._dateTime);
}

String getLocation(String name) => name;

enum DateTimeComponents {
  time,
  dayOfWeekAndTime,
  dayOfMonthAndTime,
  dateAndTime,
}
