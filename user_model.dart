import 'package:nutrilligent/models/body_progress_photo_model.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String gender;
  final String birthDate;
  final int height;
  final int weight;
  final String weightUnit;
  final String targetWeight;
  final String activityLevel;
  final String calorieBudget;
  final int steps;
  final int estimatedWeeks;
  final String? photoUrl;
  final List<BodyProgressPhoto> bodyProgressPhotos;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.gender,
    required this.birthDate,
    required this.height,
    required this.weight,
    required this.weightUnit,
    required this.targetWeight,
    required this.activityLevel,
    required this.calorieBudget,
    required this.steps,
    required this.estimatedWeeks,
    this.photoUrl,
    required this.bodyProgressPhotos,
  });

  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      gender: data['gender'] ?? 'other',
      birthDate: data['birthDate'] ?? '01-Jan-2000',
      height: (data['height'] as num?)?.toInt() ?? 0,
      weight: (data['weight'] as num?)?.toInt() ?? 0,
      weightUnit:
          data['weightUnit']?.toString().toLowerCase() == 'lbs' ? 'lbs' : 'kg',
      targetWeight: data['targetWeight']?.toString() ?? '0',
      activityLevel:
          data['activityLevel']?.toString().toLowerCase() ?? 'sedentary',
      calorieBudget: data['calorieBudget']?.toString() ?? '2000',
      steps: (data['steps'] as num?)?.toInt() ?? 0,
      estimatedWeeks: (data['estimatedWeeks'] as num?)?.toInt() ?? 0,
      photoUrl: data['photoUrl']?.toString(),
      bodyProgressPhotos: (data['bodyProgressPhotos'] as List<dynamic>? ?? [])
          .map((p) => BodyProgressPhoto.fromMap(Map<String, dynamic>.from(p)))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'gender': gender,
        'birthDate': birthDate,
        'height': height,
        'weight': weight,
        'weightUnit': weightUnit,
        'targetWeight': targetWeight,
        'activityLevel': activityLevel,
        'calorieBudget': calorieBudget,
        'steps': steps,
        'estimatedWeeks': estimatedWeeks,
        'bodyProgressPhotos': bodyProgressPhotos.map((p) => p.toMap()).toList(),
        if (photoUrl != null) 'photoUrl': photoUrl,
      };

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? gender,
    String? birthDate,
    int? height,
    int? weight,
    String? weightUnit,
    String? targetWeight,
    String? activityLevel,
    String? calorieBudget,
    int? steps,
    int? estimatedWeeks,
    String? photoUrl,
    List<BodyProgressPhoto>? bodyProgressPhotos,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      weightUnit: weightUnit ?? this.weightUnit,
      targetWeight: targetWeight ?? this.targetWeight,
      activityLevel: activityLevel ?? this.activityLevel,
      calorieBudget: calorieBudget ?? this.calorieBudget,
      steps: steps ?? this.steps,
      estimatedWeeks: estimatedWeeks ?? this.estimatedWeeks,
      photoUrl: photoUrl ?? this.photoUrl,
      bodyProgressPhotos: bodyProgressPhotos ?? this.bodyProgressPhotos,
    );
  }

  int get age {
    try {
      final parts = birthDate.split('-');
      if (parts.length != 3) return 0;

      final day = int.tryParse(parts[0]) ?? 1;
      final month = _monthFromName(parts[1]);
      final year = int.tryParse(parts[2]) ?? 2000;

      final birthday = DateTime(year, month, day);
      final now = DateTime.now();
      int age = now.year - birthday.year;
      if (now.month < birthday.month ||
          (now.month == birthday.month && now.day < birthday.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return 0;
    }
  }

  static int _monthFromName(String monthName) {
    const months = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };
    return months[monthName] ?? 1;
  }
}
