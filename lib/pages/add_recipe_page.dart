import 'package:flutter/material.dart';
import 'package:foodie_app/models/recipe.dart';
import 'package:foodie_app/services/recipe_service.dart';

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({super.key});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _stepsController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _timeController = TextEditingController();

  String _selectedCategory = "Makanan Berat";
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _ingredientsController.dispose();
    _stepsController.dispose();
    _imageUrlController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        Recipe newRecipe = Recipe(
          id: '', // API akan generate otomatis
          title: _titleController.text,
          ingredients: _ingredientsController.text,
          steps: _stepsController.text,
          category: _selectedCategory,
          cookingTime: _timeController.text,
          imageUrl: _imageUrlController.text.isEmpty
              ? 'https://via.placeholder.com/400x300.png?text=No+Image'
              : _imageUrlController.text,
        );

        await RecipeService.createRecipe(newRecipe);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Resep berhasil ditambahkan!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(
            context,
            true,
          ); // kembali ke HomePage dengan result true
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menambahkan resep: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Resep Baru"),
        backgroundColor: Colors.deepOrangeAccent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Judul Resep
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: "Judul Resep",
                    hintText: "Contoh: Nasi Goreng Spesial",
                    prefixIcon: const Icon(Icons.restaurant_menu),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Judul resep wajib diisi" : null,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Kategori (Dropdown)
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: "Kategori",
                    prefixIcon: const Icon(Icons.category),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  items:
                      [
                            "Makanan Berat",
                            "Cemilan",
                            "Minuman",
                            "Dessert",
                            "Breakfast",
                            "Lunch",
                            "Dinner",
                          ]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Bahan-bahan
                TextFormField(
                  controller: _ingredientsController,
                  decoration: InputDecoration(
                    labelText: "Bahan-bahan",
                    hintText: "Pisahkan dengan enter untuk setiap bahan",
                    prefixIcon: const Icon(Icons.shopping_basket),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  validator: (value) =>
                      value!.isEmpty ? "Bahan-bahan wajib diisi" : null,
                ),
                const SizedBox(height: 16),

                // Langkah-langkah
                TextFormField(
                  controller: _stepsController,
                  decoration: InputDecoration(
                    labelText: "Langkah-langkah",
                    hintText: "Tulis cara memasak secara detail",
                    prefixIcon: const Icon(Icons.format_list_numbered),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  validator: (value) =>
                      value!.isEmpty ? "Langkah-langkah wajib diisi" : null,
                ),
                const SizedBox(height: 16),

                // Waktu Masak
                TextFormField(
                  controller: _timeController,
                  decoration: InputDecoration(
                    labelText: "Waktu Masak",
                    hintText: "Contoh: 30 menit",
                    prefixIcon: const Icon(Icons.schedule),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Waktu masak wajib diisi" : null,
                ),
                const SizedBox(height: 16),

                // URL Gambar
                TextFormField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(
                    labelText: "URL Gambar (opsional)",
                    hintText: "https://example.com/image.jpg",
                    prefixIcon: const Icon(Icons.image),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 24),

                // Tombol Simpan
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Simpan Resep",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
