class Workout {
  final String title;
  final String imageUrl;
  final String duration;
  final String difficulty;
  final String goal;
  final String description;
  final List<String> muscleGroups;
  final List<String> equipment;
  final String videoUrl;
  final Map<String, List<String>> schedule;

  Workout({
    required this.title,
    required this.imageUrl,
    required this.duration,
    required this.difficulty,
    required this.goal,
    required this.description,
    required this.muscleGroups,
    required this.equipment,
    required this.videoUrl,
    required this.schedule,
  });

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      title: map['title'],
      imageUrl: map['imageUrl'],
      duration: map['duration'],
      difficulty: map['difficulty'],
      goal: map['goal'],
      description: map['description'],
      muscleGroups: List<String>.from(map['muscleGroups']),
      equipment: List<String>.from(map['equipment']),
      videoUrl: map['videoUrl'],
      schedule: Map<String, List<String>>.fromEntries(
        (map['schedule'] as Map<String, dynamic>).entries.map(
          (e) => MapEntry(e.key, List<String>.from(e.value)),
        ),
      ),
    );
  }
}
