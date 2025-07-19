import 'package:flutter/material.dart';
import '../models/weekly_stats_model.dart';
import '../extensions/string_extensions.dart';
class WeekReviewCard extends StatelessWidget {
  final WeeklyStats stats;

  const WeekReviewCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Week in Review", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text("📊 Total Calories: ${stats.totalCalories.toStringAsFixed(0)}", style: TextStyle(color: Colors.white70)),
          Text("👟 Avg Steps: ${stats.averageSteps.toStringAsFixed(0)}", style: TextStyle(color: Colors.white70)),
          Text("💧 Avg Water: ${stats.averageWater.toStringAsFixed(1)} cups", style: TextStyle(color: Colors.white70)),
          Text("🍽️ Frequent Meal: ${stats.mostFrequentMeal.capitalize()}", style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
