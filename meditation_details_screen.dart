import 'package:flutter/material.dart';
import 'package:nutrilligent/widgets/youtube_video_iframe.dart';
import '../models/meditation_model.dart';

class MeditationDetailScreen extends StatelessWidget {
  final Meditation meditation;

  const MeditationDetailScreen({
    super.key,
    required this.meditation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(meditation.title, style: const TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (meditation.videoUrl.isNotEmpty) ...[
              const Text(
                "Guided Meditation",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              YouTubeIframePlayer(videoUrl: meditation.videoUrl),
              const SizedBox(height: 24),
            ],
            Text(
              "Duration: ${meditation.duration}",
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              "Description",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              meditation.description,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
