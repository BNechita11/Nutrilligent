import 'package:cloud_firestore/cloud_firestore.dart';

class BodyProgressPhoto {
  final String imageUrl;
  final String? note;
  final DateTime timestamp;

  BodyProgressPhoto({
    required this.imageUrl,
    required this.timestamp,
    this.note,
  });

  factory BodyProgressPhoto.fromMap(Map<String, dynamic> map) {
    return BodyProgressPhoto(
      imageUrl: map['imageUrl'] ?? '',
      note: map['note'],
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'note': note,
      'timestamp': timestamp, 
    };
  }
}
