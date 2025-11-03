// lib/pages/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:foodie_app/models/recipe.dart';
import 'package:foodie_app/services/recipe_service.dart';
import 'package:foodie_app/pages/add_recipe_page.dart';
import 'package:foodie_app/pages/edit_recipe_page.dart';
import 'package:foodie_app/pages/detail_recipe_page.dart';

enum ViewMode { list, grid }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Recipe>> futureRecipes;
  ViewMode _mode = ViewMode.list;

  @override
  void initState() {
    super.initState();
    futureRecipes = RecipeService.fetchRecipes();
  }

  Future<void> _refresh() async {
    setState(() {
      futureRecipes = RecipeService.fetchRecipes();
    });
  }

  void _navigateToAddRecipe() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddRecipePage()),
    );

    if (result == true) {
      _refresh();
    }
  }

  void _navigateToDetail(Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailRecipePage(recipe: recipe)),
    );
  }

  // 📝 FUNGSI EDIT RESEP
  void _navigateToEdit(Recipe recipe) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditRecipePage(recipe: recipe)),
    );

    // Jika berhasil update, refresh data
    if (result == true) {
      _refresh();
    }
  }

  // 🗑️ FUNGSI DELETE DENGAN KONFIRMASI
  void _confirmDelete(Recipe recipe) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            const Text('Hapus Resep?'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus resep "${recipe.title}"?\n\nData yang sudah dihapus tidak dapat dikembalikan.',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // Tutup dialog
              await _deleteRecipe(recipe);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRecipe(Recipe recipe) async {
    // Tampilkan loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await RecipeService.deleteRecipe(recipe.id);

      if (mounted) {
        Navigator.pop(context); // Tutup loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ "${recipe.title}" berhasil dihapus'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        _refresh(); // Refresh data
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Tutup loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal menghapus resep: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Foodie Recipes"),
        backgroundColor: Colors.deepOrangeAccent,
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: _mode == ViewMode.list
                ? "Tampilkan sebagai kartu"
                : "Tampilkan sebagai daftar",
            icon: Icon(
              _mode == ViewMode.list
                  ? Icons.grid_view_rounded
                  : Icons.view_list_rounded,
            ),
            onPressed: () {
              setState(() {
                _mode = _mode == ViewMode.list ? ViewMode.grid : ViewMode.list;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<Recipe>>(
        future: futureRecipes,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    "Error: ${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: const Text("Coba Lagi"),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          if (data.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Belum ada resep 😶",
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tap tombol + untuk menambah resep",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _mode == ViewMode.list
                  ? _RecipeListView(
                      key: const ValueKey('list'),
                      data: data,
                      onTap: _navigateToDetail,
                      onEdit: _navigateToEdit,
                      onDelete: _confirmDelete,
                    )
                  : _RecipeGridView(
                      key: const ValueKey('grid'),
                      data: data,
                      onTap: _navigateToDetail,
                      onEdit: _navigateToEdit,
                      onDelete: _confirmDelete,
                    ),
            ),
          );
        },
      ),
      backgroundColor: theme.colorScheme.surface,
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddRecipe,
        backgroundColor: Colors.deepOrangeAccent,
        tooltip: "Tambah Resep",
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _RecipeListView extends StatelessWidget {
  final List<Recipe> data;
  final Function(Recipe) onTap;
  final Function(Recipe) onEdit;
  final Function(Recipe) onDelete;

  const _RecipeListView({
    super.key,
    required this.data,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: data.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final r = data[i];
        return Card(
          elevation: 1.5,
          shape: RoundedRectangleBorder(borderRadius: radius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => onTap(r),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _NetworkImageThumb(url: r.imageUrl, size: 56),
              ),
              title: Text(
                r.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Row(
                children: [
                  _ChipText(label: r.category),
                  const SizedBox(width: 8),
                  const Icon(Icons.schedule_rounded, size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      r.cookingTime,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tombol Edit
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    color: Colors.blue,
                    tooltip: 'Edit',
                    onPressed: () => onEdit(r),
                  ),
                  // Tombol Delete
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    color: Colors.red,
                    tooltip: 'Hapus',
                    onPressed: () => onDelete(r),
                  ),
                ],
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RecipeGridView extends StatelessWidget {
  final List<Recipe> data;
  final Function(Recipe) onTap;
  final Function(Recipe) onEdit;
  final Function(Recipe) onDelete;

  const _RecipeGridView({
    super.key,
    required this.data,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: data.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3 / 4,
      ),
      itemBuilder: (context, i) {
        final r = data[i];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: radius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => onTap(r),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _NetworkImageCover(url: r.imageUrl),
                const _BottomGradient(),

                // Tombol Edit & Delete di pojok kanan atas
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      // Tombol Edit
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          color: Colors.blue,
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(),
                          onPressed: () => onEdit(r),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Tombol Delete
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.delete, size: 18),
                          color: Colors.red,
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(),
                          onPressed: () => onDelete(r),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      _ChipText(label: r.category),
                      const SizedBox(height: 6),
                      Text(
                        r.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              r.cookingTime,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NetworkImageThumb extends StatelessWidget {
  final String url;
  final double size;
  const _NetworkImageThumb({required this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: size,
        height: size,
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_rounded),
      ),
      loadingBuilder: (context, child, loading) {
        if (loading == null) return child;
        return Container(
          width: size,
          height: size,
          color: Colors.grey.shade100,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }
}

class _NetworkImageCover extends StatelessWidget {
  final String url;
  const _NetworkImageCover({required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_rounded, size: 32),
      ),
      loadingBuilder: (context, child, loading) {
        if (loading == null) return child;
        return Container(
          color: Colors.grey.shade100,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }
}

class _BottomGradient extends StatelessWidget {
  const _BottomGradient();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: IgnorePointer(
        child: Container(
          height: 140,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0, -0.2),
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black54, Colors.black87],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChipText extends StatelessWidget {
  final String label;
  const _ChipText({required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.primary.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: scheme.primary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
