import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/weekly_stats_model.dart';

class WeeklyStatsService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<WeeklyStats> fetchLast7DaysStats() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    final now = DateTime.now();
    final List<DailyStat> stats = [];

    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: i));
      final docId = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";

      final doc = await _firestore
          .collection("users")
          .doc(uid)
          .collection("dailyStats")
          .doc(docId)
          .get();

      if (doc.exists) {
        final d = doc.data()!;
        stats.add(
          DailyStat(
            date: day,
            calories: (d["caloriesConsumed"] ?? 0).toDouble(),
            steps: (d["steps"] ?? 0),
            water: (d["water"] ?? 0),
            meals: {
              "breakfast": d["breakfast"] ?? 0,
              "lunch": d["lunch"] ?? 0,
              "dinner": d["dinner"] ?? 0,
              "snacks": d["snacks"] ?? 0,
            },
          ),
        );
      }
    }

    return WeeklyStats(stats.reversed.toList()); 
  }
}
