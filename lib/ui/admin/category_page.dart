import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../data/models/models.dart';
import '../../../providers/admin_provider.dart';
import '../widgets/modern_widgets.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchCategories();
    });
  }

  void _showForm({Category? category}) {
    final nameCtrl = TextEditingController(text: category?.name ?? '');
    final admin = context.read<AdminProvider>();
    int? parentId = category?.parentId;
    final candidates = admin.categories.where((c) => c.id != category?.id).toList();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) => AlertDialog(
          title: Text(category == null ? 'Tambah Kategori' : 'Edit Kategori'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Kategori *')),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                value: parentId,
                decoration: const InputDecoration(labelText: 'Induk (opsional)'),
                items: [
                  const DropdownMenuItem<int?>(value: null, child: Text('— Tanpa induk (utama) —')),
                  ...candidates.map((c) => DropdownMenuItem<int?>(value: c.id, child: Text(c.name))),
                ],
                onChanged: (v) => setM(() => parentId = v),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            TextButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                bool ok = category == null
                    ? await admin.createCategory(nameCtrl.text.trim(), parentId: parentId)
                    : await admin.updateCategory(category.id, nameCtrl.text.trim(), parentId: parentId);
                if (mounted) {
                  Navigator.pop(ctx);
                  if (!ok) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(admin.errorMessage ?? 'Gagal')));
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori'),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: () => _showForm())],
      ),
      body: RefreshIndicator(
        onRefresh: () => admin.fetchCategories(),
        child: admin.categories.isEmpty
            ? const Center(child: Text('Belum ada kategori'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: admin.categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) {
                  final c = admin.categories[i];
                  final parentName = c.parentId != null
                      ? admin.categories.where((x) => x.id == c.parentId).map((x) => x.name).firstOrNull
                      : null;
                  return ModernCard(
                    padding: const EdgeInsets.all(12),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.category, color: AppColors.primary),
                      ),
                      title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: parentName != null ? Text('Induk: $parentName', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)) : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit, size: 20, color: AppColors.primary), onPressed: () => _showForm(category: c)),
                          IconButton(icon: const Icon(Icons.delete, size: 20, color: AppColors.statusError), onPressed: () => admin.deleteCategory(c.id)),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
