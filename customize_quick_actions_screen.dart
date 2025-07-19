import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quick_actions_provider.dart';
import '../models/quick_actions_item.dart';

class CustomizeQuickActionsScreen extends StatelessWidget {
  const CustomizeQuickActionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuickActionsProvider>(context);
    final visible = provider.visibleActions;
    final hidden = provider.hiddenActions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Quick Actions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Visible Actions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: visible
                    .map((action) => _ActionTile(
                          item: action,
                          icon: Icons.remove,
                          onPressed: () => provider.hideAction(action.id),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 30),
              const Text("Hidden Actions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: hidden
                    .map((action) => _ActionTile(
                          item: action,
                          icon: Icons.add,
                          onPressed: () => provider.showAction(action.id),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final QuickActionItem item;
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionTile(
      {required this.item, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.purple.shade700,
          child: Icon(item.icon, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(item.label),
        const SizedBox(height: 4),
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: icon == Icons.add ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
