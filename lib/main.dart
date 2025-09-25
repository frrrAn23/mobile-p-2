import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'recipe_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => RecipeProvider(),
      child: const FoodieApp(),
    ),
  );
}

class FoodieApp extends StatelessWidget {
  const FoodieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Foodie Recipe App',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const RecipePage(),
    );
  }
}

class RecipePage extends StatelessWidget {
  const RecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    var recipeProvider = Provider.of<RecipeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Foodie Recipes"),
        backgroundColor: Colors.deepOrange,
      ),
      body: ListView.builder(
        itemCount: recipeProvider.recipes.length,
        itemBuilder: (context, index) {
          return ListTile(title: Text(recipeProvider.recipes[index]));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          recipeProvider.addRecipe(
            "Resep Baru ${recipeProvider.recipes.length + 1}",
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
