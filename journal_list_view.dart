import 'package:flutter/material.dart';
import '../../services/journal_service.dart';
import 'journal_entry_card.dart';
import 'journal_empty_state.dart';
import '../models/journal_entry_model.dart';

class JournalListView extends StatelessWidget {
  final ScrollController scrollController;
  final JournalService journalService;

  const JournalListView({
    super.key,
    required this.scrollController,
    required this.journalService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<JournalEntry>>(
      stream: journalService.entriesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final entries = snapshot.data ?? [];
        if (entries.isEmpty) {
          return const JournalEmptyState();
        }

        return ListView.builder(
          controller: scrollController,
          reverse: true,
          padding: const EdgeInsets.only(top: 16, bottom: 100),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final e = entries[index];
            return JournalEntryCard(
              entry: e,
              onDismissed: () => journalService.deleteEntry(e.id),
            );
          },
        );
      },
    );
  }
}