import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/journal_entry_model.dart';

class JournalService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<JournalEntry>> entriesStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('journalEntries')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => JournalEntry.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> addEntry(String text) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final entry = JournalEntry(
      id: '',
      text: text,
      createdAt: DateTime.now(),
    );
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('journalEntries')
        .add(entry.toMap());
  }
  Future<void> deleteEntry(String entryId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('journalEntries')
        .doc(entryId)
        .delete();
  }
}
