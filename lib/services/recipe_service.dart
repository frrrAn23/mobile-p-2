import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:foodie_app/models/recipe.dart';

class RecipeService {
  static const String baseUrl = "https://68e58ad621dd31f22cc20fee.mockapi.io/api/v1/recipes";

  static Future<List<Recipe>> fetchRecipes() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);

      // Ubah data JSON menjadi List<Recipe>
      return jsonResponse.map((data) => Recipe.fromJson(data)).toList();
    } else {
      throw Exception("Failed to load recipes");
    }
  }
}
