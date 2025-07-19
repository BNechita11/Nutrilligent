import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class WaterReminderService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  WaterReminderService(this._notificationsPlugin);

  Future<void> scheduleReminder(int hour, int minute, int id) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      'Time to drink water! 💧',
      'Stay hydrated and healthy.',
      tz.TZDateTime(
        tz.local,
        tz.TZDateTime.now(tz.local).year,
        tz.TZDateTime.now(tz.local).month,
        tz.TZDateTime.now(tz.local).day,
        hour,
        minute,
      ),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'water_channel',
          'Water Reminders',
          channelDescription: 'Reminders to drink water',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelReminder(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
