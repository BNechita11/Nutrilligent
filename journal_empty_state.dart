import 'package:flutter/material.dart';

class JournalEmptyState extends StatelessWidget {
  const JournalEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.edit_note,
            size: 64,
            color: const Color.fromARGB(255, 12, 0, 0),
          ),
          const SizedBox(height: 16),
          Text(
            'No entries yet\nStart your journaling journey!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: const Color.fromARGB(255, 2, 0, 0),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}