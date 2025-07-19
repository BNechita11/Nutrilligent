class DailyStat {
  final DateTime date;
  final double calories;
  final int steps;
  final int water;
  final Map<String, int> meals;

  DailyStat({
    required this.date,
    required this.calories,
    required this.steps,
    required this.water,
    required this.meals,
  });
}

class WeeklyStats {
  final List<DailyStat> dailyStats;

  WeeklyStats(this.dailyStats);

  double get totalCalories =>
      dailyStats.fold(0, (sum, stat) => sum + stat.calories);

  double get averageSteps =>
      dailyStats.fold(0, (sum, stat) => sum + stat.steps) / dailyStats.length;

  double get averageWater =>
      dailyStats.fold(0, (sum, stat) => sum + stat.water) / dailyStats.length;

  String get mostFrequentMeal {
    Map<String, int> count = {"breakfast": 0, "lunch": 0, "dinner": 0, "snacks": 0};
    for (var stat in dailyStats) {
      stat.meals.forEach((k, v) => count[k] = count[k]! + v);
    }
    return count.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  int daysMeetingTarget(double target) =>
      dailyStats.where((e) => e.calories <= target).length;
}
