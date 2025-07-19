import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  final String id;
  final String text;
  final DateTime createdAt;

  JournalEntry({
    required this.id,
    required this.text,
    required this.createdAt,
  });

  factory JournalEntry.fromMap(String id, Map<String, dynamic> data) {
    return JournalEntry(
      id: id,
      text: data['text'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
