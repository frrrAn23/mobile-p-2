import 'package:flutter/foundation.dart';

class RecipeProvider with ChangeNotifier {
  List<String> _recipes = ["Nasi Goreng", "Mie Ayam"];

  List<String> get recipes => _recipes;

  void addRecipe(String recipe) {
    _recipes.add(recipe);
    notifyListeners();
  }
}
