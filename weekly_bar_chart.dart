import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/weekly_stats_model.dart';

class WeeklyBarChart extends StatelessWidget {
  final List<DailyStat> stats;

  const WeeklyBarChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        titlesData: FlTitlesData(show: true, bottomTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, _) {
            final index = value.toInt();
            if (index < 0 || index >= stats.length) return Text('');
            final date = stats[index].date;
            return Text('${date.day}/${date.month}', style: TextStyle(color: Colors.white70, fontSize: 10));
          }),
        )),
        barGroups: stats.asMap().entries.map((entry) {
          final index = entry.key;
          final calories = entry.value.calories;
          return BarChartGroupData(x: index, barRods: [
            BarChartRodData(toY: calories, color: Colors.purpleAccent, width: 14),
          ]);
        }).toList(),
      ),
    );
  }
}
