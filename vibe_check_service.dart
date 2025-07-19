import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VibeCheckService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> shouldShowVibeCheck() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return true;
    final ts = (doc.data()?['vibeCheckDate'] as Timestamp?);
    if (ts == null) return true;
    final date = ts.toDate();
    final now = DateTime.now();
    return !(date.year == now.year &&
        date.month == now.month &&
        date.day == now.day);
  }

  Future<void> recordVibeCheck(String mood) async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (mood.isEmpty) return;
    
    final now = Timestamp.fromDate(DateTime.now());
    await _firestore.collection('users').doc(user.uid).set({
      'vibeMood': mood,
      'vibeCheckDate': now,
    }, SetOptions(merge: true));
  }
}
