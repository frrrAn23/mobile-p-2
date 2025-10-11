import 'package:flutter/material.dart';

class Recipe {
  final String id;
  final String title;
  final String ingredients;
  final String steps;
  final String category;
  final String cookingTime;
  final String imageUrl;

  Recipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.steps,
    required this.category,
    required this.cookingTime,
    required this.imageUrl,
  });

  IconData getIcon() {
    switch (category.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'dessert':
        return Icons.cake;
      default:
        return Icons.restaurant;
    }
  }

  // Parsing JSON → Object
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'],
      ingredients: json['ingredients'].toString(),
      steps: json['steps'] is List
          ? (json['steps'] as List).join('\n')
          : json['steps'].toString(),
      category: json['category'].toString(),
      cookingTime: json['cookingTime'].toString(),
      imageUrl: json['imageUrl'].toString(),
    );
  }

  // Convert Object → JSON (untuk Create/Update)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'ingredients': ingredients,
      'steps': steps,
      'category': category,
      'cookingTime': cookingTime,
      'imageUrl': imageUrl,
    };
  }
}
