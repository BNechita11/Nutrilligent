import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CalorieTargetRing extends StatelessWidget {
  final int daysMetTarget;
  final int totalDays;

  const CalorieTargetRing({super.key, required this.daysMetTarget, this.totalDays = 7});

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: 60,
      lineWidth: 12,
      percent: daysMetTarget / totalDays,
      center: Text("$daysMetTarget / $totalDays", style: TextStyle(color: Colors.white)),
      progressColor: Colors.greenAccent,
      backgroundColor: Colors.grey.shade800,
      animation: true,
    );
  }
}
