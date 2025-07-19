class Recipe {
  final String title;
  final String imageUrl;
  final String prepTime;
  final int calories;
  final List<String> ingredients;
  final String instructions;

  Recipe({
    required this.title,
    required this.imageUrl,
    required this.prepTime,
    required this.calories,
    required this.ingredients,
    required this.instructions,
  });

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      title: map['title'],
      imageUrl: map['imageUrl'],
      prepTime: map['prepTime'],
      calories: map['calories'],
      ingredients: List<String>.from(map['ingredients']),
      instructions: map['instructions'],
    );
  }
}
