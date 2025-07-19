import 'package:flutter/material.dart';
import '../models/recipe_model.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(recipe.title, style: const TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(recipe.imageUrl),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Prep Time: ${recipe.prepTime}",
                      style: const TextStyle(color: Colors.white70)),
                  Text("Calories: ${recipe.calories}",
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  const Text("Ingredients",
                      style:
                          TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ...recipe.ingredients.map((e) => Text("- $e", style: const TextStyle(color: Colors.white))),
                  const SizedBox(height: 16),
                  const Text("Instructions",
                      style:
                          TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(recipe.instructions, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
