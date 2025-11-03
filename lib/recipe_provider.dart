// lib/recipe_provider.dart
import 'package:flutter/foundation.dart';

/// Model sederhana untuk menyimpan data resep
class Recipe {
  final String title;
  final String category;

  Recipe({required this.title, required this.category});
}

/// Provider untuk mengelola daftar resep
class RecipeProvider with ChangeNotifier {
  final List<Recipe> _recipes = [];

  /// Getter untuk mengambil semua resep
  List<Recipe> get recipes => _recipes;

  /// Tambah resep baru ke daftar
  void addRecipe(String title, String category) {
    _recipes.add(Recipe(title: title, category: category));
    notifyListeners(); // memberitahu UI bahwa data berubah
  }

  /// Hapus resep berdasarkan index
  void removeRecipe(int index) {
    _recipes.removeAt(index);
    notifyListeners(); // update UI
  }

  /// Edit resep pada index tertentu
  void editRecipe(int index, String newTitle, String newCategory) {
    _recipes[index] = Recipe(title: newTitle, category: newCategory);
    notifyListeners(); // update UI
  }
}
