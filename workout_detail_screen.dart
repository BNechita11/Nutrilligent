import 'package:flutter/material.dart';
import '../models/workout_model.dart';
import 'package:nutrilligent/screens/workout_schedule_screen.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final Workout workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(workout.title, style: const TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(workout.imageUrl),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Goal: ${workout.goal}", style: const TextStyle(color: Colors.white70)),
                  Text("Duration: ${workout.duration}", style: const TextStyle(color: Colors.white70)),
                  Text("Difficulty: ${workout.difficulty}", style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 12),
                  Text("Muscle Groups: ${workout.muscleGroups.join(', ')}", style: const TextStyle(color: Colors.white70)),
                  Text("Equipment: ${workout.equipment.join(', ')}", style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  const Text("Description", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(workout.description, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkoutScheduleScreen(workout: workout),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      ),
                      child: const Text("View Schedule + Video"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
