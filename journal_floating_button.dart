import 'package:flutter/material.dart';

class JournalFloatingButton extends StatelessWidget {
  final VoidCallback onPressed;

  const JournalFloatingButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 70.0, right: 1.0),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.arrow_downward),
      ),
    );
  }
}