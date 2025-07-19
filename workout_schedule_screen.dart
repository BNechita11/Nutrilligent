import 'package:flutter/material.dart';
import 'package:nutrilligent/models/workout_model.dart';
import 'package:nutrilligent/widgets/youtube_video_iframe.dart';

class WorkoutScheduleScreen extends StatelessWidget {
  final Workout workout;

  const WorkoutScheduleScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Workout Schedule", style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (workout.videoUrl.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Workout Video", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  YouTubeIframePlayer(videoUrl: workout.videoUrl),
                  const SizedBox(height: 24),
                ],
              ),
            const Text("Schedule", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...workout.schedule.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key, style: const TextStyle(color: Colors.purple, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    ...entry.value.map((exercise) => Text("- $exercise", style: const TextStyle(color: Colors.white))),
                  ],
                ),
              );
            })
          ],
        ),
      ),
    );
  }
}
