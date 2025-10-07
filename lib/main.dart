import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'recipe_provider.dart';

void main() {
  runApp(
    /// Bungkus aplikasi dengan [ChangeNotifierProvider]
    /// agar RecipeProvider bisa diakses dari semua widget
    ChangeNotifierProvider(
      create: (_) => RecipeProvider(),
      child: const RecipeApp(),
    ),
  );
}

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const RecipeScreen(),
    );
  }
}

/// Halaman utama untuk menampilkan daftar resep
class RecipeScreen extends StatelessWidget {
  const RecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    /// Ambil data dari provider
    final recipeProvider = Provider.of<RecipeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Foodie Recipe Apps")),

      /// Jika list kosong, tampilkan teks
      body: recipeProvider.recipes.isEmpty
          ? const Center(child: Text("Belum ada resep"))
          /// Jika ada, tampilkan dalam ListView
          : ListView.builder(
              itemCount: recipeProvider.recipes.length,
              itemBuilder: (ctx, i) {
                final recipe = recipeProvider.recipes[i];

                return Dismissible(
                  /// Key unik untuk setiap item
                  key: ValueKey(recipe.title + recipe.category),

                  /// Hanya bisa geser dari kanan ke kiri
                  direction: DismissDirection.endToStart,

                  /// Background merah dengan ikon delete saat swipe
                  background: Container(
                    color: Colors.red,
                    padding: const EdgeInsets.only(right: 20),
                    alignment: Alignment.centerRight,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),

                  /// Aksi ketika item dihapus dengan swipe
                  onDismissed: (_) {
                    recipeProvider.removeRecipe(i);

                    /// Tampilkan notifikasi snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${recipe.title} dihapus"),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },

                  /// Tampilan item resep
                  child: ListTile(
                    title: Text(recipe.title),
                    subtitle: Text(recipe.category),

                    /// Tekan lama (long press) untuk edit resep
                    onLongPress: () {
                      _showEditRecipeDialog(context, i, recipe);
                    },
                  ),
                );
              },
            ),

      /// FloatingActionButton untuk menambah resep baru
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddRecipeDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Dialog untuk menambahkan resep baru
  void _showAddRecipeDialog(BuildContext context) {
    final titleController = TextEditingController();
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Tambah Resep Baru"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Input judul resep
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Judul"),
              ),

              /// Input kategori resep
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: "Kategori"),
              ),
            ],
          ),
          actions: [
            /// Tombol batal
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text("Batal"),
            ),

            /// Tombol simpan resep
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    categoryController.text.isNotEmpty) {
                  Provider.of<RecipeProvider>(
                    context,
                    listen: false,
                  ).addRecipe(titleController.text, categoryController.text);
                  Navigator.of(ctx).pop(); // tutup dialog
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  /// Dialog untuk mengedit resep
  void _showEditRecipeDialog(BuildContext context, int index, Recipe recipe) {
    final titleController = TextEditingController(text: recipe.title);
    final categoryController = TextEditingController(text: recipe.category);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Edit Resep"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Input judul baru
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Judul"),
              ),

              /// Input kategori baru
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: "Kategori"),
              ),
            ],
          ),
          actions: [
            /// Tombol batal
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text("Batal"),
            ),

            /// Tombol update resep
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    categoryController.text.isNotEmpty) {
                  Provider.of<RecipeProvider>(
                    context,
                    listen: false,
                  ).editRecipe(
                    index,
                    titleController.text,
                    categoryController.text,
                  );
                  Navigator.of(ctx).pop(); // tutup dialog
                }
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }
}

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: const Text("Foodie Recipes")),
  //     body: FutureBuilder<List<Recipe>>(
  //       future: futureRecipes,
  //       builder: (context, snapshot) {
  //         if (snapshot.hasData) {
  //           return ListView.builder(
  //             itemCount: snapshot.data!.length,
  //             itemBuilder: (context, index) {
  //               var recipe = snapshot.data![index];
  //               return ListTile(
  //                 title: Text(recipe.title),
  //                 subtitle: Text(recipe.category),
  //               );
  //             },
  //           );
  //         } else if (snapshot.hasError) {
  //           return Center(child: Text("Error: ${snapshot.error}"));
  //         }
  //         return const Center(child: CircularProgressIndicator());
  //       },
  //     ),
  //   );
  // }
