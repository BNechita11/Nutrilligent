import 'package:flutter/material.dart';
import 'package:nutrilligent/screens/customize_quick_actions_screen.dart';
import 'package:provider/provider.dart';
import '../providers/quick_actions_provider.dart';
import '../screens/water_reminder_screen.dart';
import 'package:nutrilligent/main.dart';

class QuickActionsPopup extends StatelessWidget {
  const QuickActionsPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final visibleActions =
        Provider.of<QuickActionsProvider>(context).visibleActions;

    return Dialog(
      backgroundColor: Colors.black.withAlpha((0.95 * 255).round()),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Quick Actions",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CustomizeQuickActionsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: visibleActions
                      .map((action) => _QuickAction(
                          icon: action.icon,
                          label: action.label,
                          id: action.id))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String id;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop(); 

        if (id == 'water') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WaterReminderScreen(
                notificationsPlugin: flutterLocalNotificationsPlugin,
              ),
            ),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.purple.shade700,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
