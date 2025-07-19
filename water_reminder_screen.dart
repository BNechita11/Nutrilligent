import 'package:flutter/material.dart';
import '../services/water_reminder_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class WaterReminderScreen extends StatefulWidget {
  final FlutterLocalNotificationsPlugin notificationsPlugin;

  const WaterReminderScreen({super.key, required this.notificationsPlugin});

  @override
  State<WaterReminderScreen> createState() => _WaterReminderScreenState();
}

class _WaterReminderScreenState extends State<WaterReminderScreen> {
  late WaterReminderService _reminderService;

  @override
  void initState() {
    super.initState();
    _reminderService = WaterReminderService(widget.notificationsPlugin);
  }

  void _schedule8AMReminder() {
    _reminderService.scheduleReminder(8, 0, 100);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reminder set for 8:00 AM')),
    );
  }

  void _cancelReminder() {
    _reminderService.cancelReminder(100);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reminder cancelled')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title:
            const Text('Water Reminder', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _schedule8AMReminder,
              child: const Text("Set 8:00 AM Reminder"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cancelReminder,
              child: const Text("Cancel Reminder"),
            ),
          ],
        ),
      ),
    );
  }
}
