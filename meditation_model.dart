class Meditation {
  final String id;
  final String title;
  final String imageUrl;
  final String duration;
  final String description;
  final String videoUrl;

  Meditation({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.duration,
    required this.description,
    required this.videoUrl,
  });

  factory Meditation.fromMap(String id, Map<String, dynamic> map) {
    return Meditation(
      id: id,
      title: map['title'] as String,
      imageUrl: map['imageUrl'] as String,
      duration: map['duration'] as String,
      description: map['description'] as String,
      videoUrl: map['videoUrl'] as String, 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'duration': duration,
      'description': description,
      'videoUrl': videoUrl,
    };
  }
}
