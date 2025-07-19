import 'package:flutter/material.dart';
import 'package:nutrilligent/widgets/advice_card.dart';

class AdviceSection extends StatelessWidget {
  final Future<List<Map<String, String>>> Function() fetchAdvice;

  const AdviceSection({super.key, required this.fetchAdvice});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchAdvice(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Loading community...",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          );
        }

        List<Map<String, String>> adviceList = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "My Daily Advice",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: adviceList.map((advice) {
                return AdviceCard(
                  title: advice["title"] ?? "No Title",
                  content: advice["content"] ?? "No Content",
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
