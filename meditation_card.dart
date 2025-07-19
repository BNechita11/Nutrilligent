import 'package:flutter/material.dart';
import '../models/meditation_model.dart';

class MeditationCard extends StatelessWidget {
  final Meditation meditation;
  final VoidCallback onTap;

  const MeditationCard({
    super.key,
    required this.meditation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(meditation.imageUrl),
            fit: BoxFit.cover,
            colorFilter: const ColorFilter.mode(
              Color.fromRGBO(0, 0, 0, 0.35),
              BlendMode.darken,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              meditation.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 4, color: Colors.black)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
