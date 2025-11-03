// lib/pages/edit_recipe_page.dart
import 'package:flutter/material.dart';
import 'package:foodie_app/models/recipe.dart';
import 'package:foodie_app/services/recipe_service.dart';

class EditRecipePage extends StatefulWidget {
  final Recipe recipe;

  const EditRecipePage({super.key, required this.recipe});

  @override
  State<EditRecipePage> createState() => _EditRecipePageState();
}

class _EditRecipePageState extends State<EditRecipePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _ingredientsController;
  late TextEditingController _stepsController;
  late TextEditingController _imageUrlController;
  late TextEditingController _timeController;

  // Daftar kategori yang tersedia
  static const List<String> _availableCategories = [
    "Makanan Berat",
    "Cemilan",
    "Minuman",
    "Dessert",
    "Breakfast",
    "Lunch",
    "Dinner",
  ];

  late String _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data resep yang ada
    _titleController = TextEditingController(text: widget.recipe.title);
    _ingredientsController = TextEditingController(
      text: widget.recipe.ingredients,
    );
    _stepsController = TextEditingController(text: widget.recipe.steps);
    _imageUrlController = TextEditingController(text: widget.recipe.imageUrl);
    _timeController = TextEditingController(text: widget.recipe.cookingTime);

    // Validasi kategori - gunakan kategori dari data jika ada,
    // jika tidak ada gunakan kategori default
    if (_availableCategories.contains(widget.recipe.category)) {
      _selectedCategory = widget.recipe.category;
    } else {
      // Jika kategori tidak ada dalam list, gunakan default
      _selectedCategory = _availableCategories[0];
      // Tampilkan info ke user bahwa kategori telah diubah
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Kategori "${widget.recipe.category}" tidak tersedia. Diganti ke "${_selectedCategory}"',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      });
    }
  }

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
        Recipe updatedRecipe = Recipe(
          id: widget.recipe.id, // Gunakan ID yang sama
          title: _titleController.text,
          ingredients: _ingredientsController.text,
          steps: _stepsController.text,
          category: _selectedCategory,
          cookingTime: _timeController.text,
          imageUrl: _imageUrlController.text.isEmpty
              ? 'https://via.placeholder.com/400x300.png?text=No+Image'
              : _imageUrlController.text,
        );

        // Panggil API untuk update
        await RecipeService.updateRecipe(widget.recipe.id, updatedRecipe);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Resep berhasil diperbarui!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context, true); // Kembali dengan result true
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Gagal memperbarui resep: $e'),
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
        title: const Text("Edit Resep"),
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
                // Info: Data yang sedang diedit
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Anda sedang mengedit: ${widget.recipe.title}',
                          style: TextStyle(
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

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
                  items: _availableCategories
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
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

                // Tombol Update
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
                          "💾 Update Resep",
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
