import 'package:flutter/material.dart';
import '../models/quick_actions_item.dart';


class QuickActionsProvider with ChangeNotifier {
  final List<QuickActionItem> _visibleActions = [
    QuickActionItem(id: 'exercise', icon: Icons.fitness_center, label: 'Exercise'),
    QuickActionItem(id: 'water', icon: Icons.local_drink, label: 'Water'),
    QuickActionItem(id: 'weight', icon: Icons.monitor_weight, label: 'Weight'),
    QuickActionItem(id: 'breakfast', icon: Icons.wb_sunny, label: 'Breakfast'),
    QuickActionItem(id: 'lunch', icon: Icons.lunch_dining, label: 'Lunch'),
    QuickActionItem(id: 'dinner', icon: Icons.nightlight, label: 'Dinner'),
    QuickActionItem(id: 'snacks', icon: Icons.apple, label: 'Snacks'),
    QuickActionItem(id: 'voice', icon: Icons.mic, label: 'Voice Input'),
  ];

  final List<QuickActionItem> _hiddenActions = [
    QuickActionItem(id: 'notes', icon: Icons.note, label: 'Notes'),
    QuickActionItem(id: 'quick_entry', icon: Icons.add_circle, label: 'Quick Entry'),
  ];

  List<QuickActionItem> get visibleActions => _visibleActions;
  List<QuickActionItem> get hiddenActions => _hiddenActions;

  void hideAction(String id) {
    final action = _visibleActions.firstWhere((item) => item.id == id);
    _visibleActions.remove(action);
    _hiddenActions.add(action);
    notifyListeners();
  }

  void showAction(String id) {
    final action = _hiddenActions.firstWhere((item) => item.id == id);
    _hiddenActions.remove(action);
    _visibleActions.add(action);
    notifyListeners();
  }
}
