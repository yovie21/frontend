import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/models.dart';
import '../../../providers/admin_provider.dart';
import '../widgets/modern_widgets.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().initAdminData();
    });
  }

  void _showForm({Category? category}) {
    final nameCtrl = TextEditingController(text: category?.name ?? '');
    final admin = context.read<AdminProvider>();
    int? parentId = category?.parentId;
    final candidates = admin.categories.where((c) => c.id != category?.id).toList();

    const quickSuggestions = [
      'Minuman',
      'Makanan Ringan',
      'Sembako & Beras',
      'Rokok & Tembakau',
      'Obat & Kesehatan',
      'Sabun & Kebersihan',
      'Bumbu Dapur',
      'Perkakas & Alat',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) {
          final currentName = nameCtrl.text.trim();
          final previewName = currentName.isEmpty ? 'Nama Kategori' : currentName;
          final previewTheme = _getCategoryTheme(currentName);
          final parentCat = parentId != null ? candidates.where((x) => x.id == parentId).map((x) => x.name).firstOrNull : null;

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.category_rounded, color: Color(0xFF0F3826), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        category == null ? 'Tambah Kategori' : 'Edit Kategori',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Live Preview Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: previewTheme.bg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(previewTheme.icon, color: previewTheme.color, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'PRATINJAU TAMPILAN',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.5),
                              ),
                              Text(
                                previewName,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: currentName.isEmpty ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                                ),
                              ),
                              if (parentCat != null)
                                Text(
                                  '↳ Sub dari: $parentCat',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quick Suggestion Chips
                  const Text(
                    'PILIHAN CEPAT (KLIK UNTUK MENGISI):',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: quickSuggestions.map((s) {
                      final isSelected = nameCtrl.text == s;
                      return InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          setM(() => nameCtrl.text = s);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF0F3826) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF0F3826) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Text(
                            s,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : const Color(0xFF334155),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nama Kategori *',
                      hintText: 'Masukkan nama kategori produk',
                      prefixIcon: Icon(Icons.label_outline_rounded),
                    ),
                    onChanged: (_) => setM(() {}),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<int?>(
                    value: parentId,
                    decoration: const InputDecoration(
                      labelText: 'Induk Kategori (Opsional)',
                      prefixIcon: Icon(Icons.account_tree_outlined),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('— Kategori Utama (Tanpa Induk) —', style: TextStyle(color: Color(0xFF64748B))),
                      ),
                      ...candidates.map((c) => DropdownMenuItem<int?>(
                            value: c.id,
                            child: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          )),
                    ],
                    onChanged: (v) => setM(() => parentId = v),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F3826),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) return;
                      Navigator.pop(ctx);
                      bool ok = category == null
                          ? await admin.createCategory(name, parentId: parentId)
                          : await admin.updateCategory(category.id, name, parentId: parentId);
                      if (mounted && !ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(backgroundColor: const Color(0xFFDC2626), content: Text(admin.errorMessage ?? 'Gagal menyimpan kategori')),
                        );
                      }
                    },
                    child: const Text('Simpan Kategori', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Category c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Kategori', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        content: Text(
          'Yakin ingin menghapus kategori "${c.name}"?\nProduk di dalam kategori ini tidak akan terhapus.',
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminProvider>().deleteCategory(c.id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // Thematic Category Visual Style
  _CategoryTheme _getCategoryTheme(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('minum') || lower.contains('drink') || lower.contains('beverage') || lower.contains('kopi') || lower.contains('teh') || lower.contains('air')) {
      return _CategoryTheme(Icons.local_drink_rounded, const Color(0xFFEFF6FF), const Color(0xFF2563EB));
    }
    if (lower.contains('makan') || lower.contains('food') || lower.contains('snack') || lower.contains('mie') || lower.contains('roti') || lower.contains('dryfood')) {
      return _CategoryTheme(Icons.lunch_dining_rounded, const Color(0xFFFFFBEB), const Color(0xFFD97706));
    }
    if (lower.contains('obat') || lower.contains('sehat') || lower.contains('medis') || lower.contains('herbal') || lower.contains('vitamin')) {
      return _CategoryTheme(Icons.medication_rounded, const Color(0xFFFEF2F2), const Color(0xFFDC2626));
    }
    if (lower.contains('rokok') || lower.contains('tembakau') || lower.contains('smoke')) {
      return _CategoryTheme(Icons.smoking_rooms_rounded, const Color(0xFFF1F5F9), const Color(0xFF475569));
    }
    if (lower.contains('fresh') || lower.contains('buah') || lower.contains('sayur') || lower.contains('telur')) {
      return _CategoryTheme(Icons.eco_rounded, const Color(0xFFECFDF5), const Color(0xFF059669));
    }
    if (lower.contains('sabun') || lower.contains('cuci') || lower.contains('detergen') || lower.contains('pembersih') || lower.contains('nonfood')) {
      return _CategoryTheme(Icons.sanitizer_rounded, const Color(0xFFFAF5FF), const Color(0xFF9333EA));
    }
    if (lower.contains('bumbu') || lower.contains('dapur') || lower.contains('sembako') || lower.contains('beras') || lower.contains('minyak')) {
      return _CategoryTheme(Icons.kitchen_rounded, const Color(0xFFF0FDF4), const Color(0xFF16A34A));
    }
    if (lower.contains('tool') || lower.contains('alat') || lower.contains('listrik') || lower.contains('perkakas')) {
      return _CategoryTheme(Icons.construction_rounded, const Color(0xFFF0FDFA), const Color(0xFF0D9488));
    }
    return _CategoryTheme(Icons.category_rounded, const Color(0xFFF0FDF4), const Color(0xFF0F3826));
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final categories = admin.categories.where((c) {
      if (_searchQuery.isEmpty) return true;
      return c.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            const Text(
              'Kelola Kategori',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Text(
                '${categories.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF065F46),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: const Color(0xFF0F3826),
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Tambah Kategori', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x040F172A),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Cari nama kategori...',
                  hintStyle: const TextStyle(fontSize: 13.5, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF94A3B8)),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
          ),

          // Overview Stats Strip
          if (_searchQuery.isEmpty && admin.categories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.folder_special_rounded, color: Color(0xFF0F3826), size: 16),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Kategori Utama', style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                              Text(
                                '${admin.categories.where((c) => c.parentId == null).length}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.account_tree_rounded, color: Color(0xFF2563EB), size: 16),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Sub-Kategori', style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                              Text(
                                '${admin.categories.where((c) => c.parentId != null).length}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Categories List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => admin.fetchCategories(),
              child: categories.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.category_outlined, size: 32, color: Color(0xFF94A3B8)),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'Tidak ada kategori sesuai "$_searchQuery"'
                                : 'Belum ada kategori yang dibuat',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF475569)),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (ctx, i) {
                        final c = categories[i];
                        final theme = _getCategoryTheme(c.name);
                        final parentName = c.parentId != null
                            ? admin.categories.where((x) => x.id == c.parentId).map((x) => x.name).firstOrNull
                            : null;
                        
                        // Count products in this category
                        final prodCount = admin.products.where((p) => p.categoryId == c.id).length;

                        return ModernCard(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              // Thematic Avatar Icon
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: theme.bg,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(theme.icon, color: theme.color, size: 24),
                              ),
                              const SizedBox(width: 14),

                              // Category Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15.5,
                                        color: Color(0xFF0F172A),
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '$prodCount Produk',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF475569),
                                            ),
                                          ),
                                        ),
                                        if (parentName != null) ...[
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              '↳ $parentName',
                                              style: const TextStyle(
                                                fontSize: 11.5,
                                                color: Color(0xFF64748B),
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Quick Action Buttons
                              InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () => _showForm(category: c),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF0F3826)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () => _confirmDelete(context, c),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFFECACA)),
                                  ),
                                  child: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFDC2626)),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTheme {
  final IconData icon;
  final Color bg;
  final Color color;

  _CategoryTheme(this.icon, this.bg, this.color);
}
