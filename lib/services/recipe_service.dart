// lib/services/recipe_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:foodie_app/models/recipe.dart';

class RecipeService {
  static const String baseUrl =
      "https://68e58ad621dd31f22cc20fee.mockapi.io/api/v1/recipes";

  /// Mengambil semua resep dari API
  static Future<List<Recipe>> fetchRecipes() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Recipe.fromJson(data)).toList();
    } else {
      throw Exception("Failed to load recipes");
    }
  }

  /// Menambah resep baru ke API (POST)
  static Future<Recipe> createRecipe(Recipe recipe) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(recipe.toJson()),
    );

    if (response.statusCode == 201) {
      return Recipe.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to create recipe: ${response.statusCode}");
    }
  }

  /// Mengupdate resep yang sudah ada (PUT)
  static Future<Recipe> updateRecipe(String id, Recipe recipe) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(recipe.toJson()),
    );

    if (response.statusCode == 200) {
      return Recipe.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to update recipe: ${response.statusCode}");
    }
  }

  /// Menghapus resep dari API (DELETE)
  static Future<void> deleteRecipe(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete recipe: ${response.statusCode}");
    }
  }
}
