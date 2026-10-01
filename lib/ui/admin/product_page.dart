import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/utils.dart';
import '../../../data/dto/dto.dart';
import '../../../data/models/models.dart';
import '../../../providers/admin_provider.dart';
import '../widgets/camera_scanner_page.dart';
import '../widgets/modern_widgets.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final _searchCtrl = TextEditingController();
  int? _selectedCategoryFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().initAdminData();
    });
  }

  void _showForm({Product? product}) {
    final namaCtrl = TextEditingController(text: product?.name ?? '');
    final skuCtrl = TextEditingController(text: product?.sku ?? '');
    final barcodeCtrl = TextEditingController(text: product?.barcode ?? '');
    final priceCtrl = TextEditingController(text: product != null ? AppUtils.formatCurrency(product.price.toInt()) : '');
    final costCtrl = TextEditingController(text: product != null ? AppUtils.formatCurrency(product.costPrice.toInt()) : '');
    final minStockCtrl = TextEditingController(text: product != null ? product.minStock.toString() : '5');
    final initialStockCtrl = TextEditingController(text: product == null ? '0' : '');

    final admin = context.read<AdminProvider>();
    final pId = product?.id;
    int? selectedCat = product?.categoryId ?? (admin.categories.isNotEmpty ? admin.categories.first.id : null);
    int? selectedUom = product?.uomId ?? (admin.uoms.isNotEmpty ? admin.uoms.first.id : null);

    List<Map<String, dynamic>> extraUoms = [];
    if (product != null && product.productUoms != null) {
      for (final pu in product.productUoms!) {
        extraUoms.add({
          'uomId': pu['uomId'] ?? (admin.uoms.isNotEmpty ? admin.uoms.first.id : 1),
          'factorCtrl': TextEditingController(text: pu['conversionFactor']?.toString() ?? '1'),
          'priceCtrl': TextEditingController(text: AppUtils.formatCurrency((pu['price'] as num?)?.toInt() ?? 0)),
        });
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 24, left: 24, right: 24, top: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(product == null ? 'Tambah Produk' : 'Edit Produk', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 24),
                TextField(controller: namaCtrl, decoration: const InputDecoration(labelText: 'Nama Produk *', prefixIcon: Icon(Icons.shopping_bag_outlined))),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: TextField(controller: skuCtrl, decoration: const InputDecoration(labelText: 'SKU *', prefixIcon: Icon(Icons.qr_code)))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: barcodeCtrl,
                      decoration: InputDecoration(
                        labelText: 'Barcode',
                        prefixIcon: const Icon(Icons.qr_code_2_rounded),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.camera_alt_rounded, color: Color(0xFF0F3826)),
                          tooltip: 'Scan dengan Kamera',
                          onPressed: () async {
                            final code = await Navigator.of(context).push<String>(
                              MaterialPageRoute(
                                builder: (_) => const CameraScannerPage(title: 'Scan Barcode Produk'),
                              ),
                            );
                            if (code != null && code.isNotEmpty) {
                              barcodeCtrl.text = code;
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: DropdownButtonFormField<int>(value: selectedCat, decoration: const InputDecoration(labelText: 'Kategori'), items: admin.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(), onChanged: (v) => selectedCat = v)),
                  const SizedBox(width: 12),
                  Expanded(child: DropdownButtonFormField<int>(value: selectedUom, decoration: const InputDecoration(labelText: 'Satuan Utama'), items: admin.uoms.map((u) => DropdownMenuItem(value: u.id, child: Text(u.symbol ?? u.name))).toList(), onChanged: (v) => selectedUom = v)),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: TextField(controller: priceCtrl, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()], decoration: const InputDecoration(labelText: 'Harga Jual Utama *', prefixText: 'Rp '))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: costCtrl, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()], decoration: const InputDecoration(labelText: 'Harga Modal *', prefixText: 'Rp '))),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  if (product == null)
                    Expanded(child: TextField(controller: initialStockCtrl, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: 'Stok Awal'))),
                  if (product == null) const SizedBox(width: 12),
                  Expanded(child: TextField(controller: minStockCtrl, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: 'Min Stok Alert'))),
                ]),

                // MULTI UOM CONVERSION SECTION
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Multi-UOM (Satuan Alternatif)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    TextButton.icon(
                      onPressed: () {
                        if (admin.uoms.isEmpty) return;
                        setM(() {
                          extraUoms.add({
                            'uomId': admin.uoms.first.id,
                            'factorCtrl': TextEditingController(text: '12'),
                            'priceCtrl': TextEditingController(text: '0'),
                          });
                        });
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Tambah UOM'),
                    ),
                  ],
                ),
                for (int i = 0; i < extraUoms.length; i++)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: extraUoms[i]['uomId'],
                                decoration: const InputDecoration(labelText: 'Satuan'),
                                items: admin.uoms.map((u) => DropdownMenuItem(value: u.id, child: Text(u.symbol ?? u.name))).toList(),
                                onChanged: (v) => setM(() => extraUoms[i]['uomId'] = v),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => setM(() => extraUoms.removeAt(i)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: extraUoms[i]['factorCtrl'],
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: const InputDecoration(labelText: 'Isi (Faktor Konversi)'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: extraUoms[i]['priceCtrl'],
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
                                decoration: const InputDecoration(labelText: 'Harga Jual UOM', prefixText: 'Rp '),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),
                ModernButton(
                  text: 'Simpan Produk',
                  onPressed: () async {
                    if (namaCtrl.text.isEmpty || skuCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;
                    final uomList = <Map<String, dynamic>>[];
                    for (var u in extraUoms) {
                      final f = int.tryParse(u['factorCtrl'].text) ?? 1;
                      final p = AppUtils.parseCurrency(u['priceCtrl'].text);
                      if (u['uomId'] != null && f > 0 && p > 0) {
                        uomList.add({
                          'uomId': u['uomId'],
                          'conversionFactor': f,
                          'price': p,
                        });
                      }
                    }

                    final dto = ProductDto(
                      name: namaCtrl.text.trim(),
                      sku: skuCtrl.text.trim(),
                      barcode: barcodeCtrl.text.trim().isEmpty ? null : barcodeCtrl.text.trim(),
                      categoryId: selectedCat,
                      uomId: selectedUom,
                      price: AppUtils.parseCurrency(priceCtrl.text),
                      costPrice: AppUtils.parseCurrency(costCtrl.text),
                      minStock: int.tryParse(minStockCtrl.text) ?? 5,
                      initialStock: product == null ? (int.tryParse(initialStockCtrl.text) ?? 0) : null,
                      productUoms: uomList,
                    );
                    bool success = pId == null ? await admin.createProduct(dto) : await admin.updateProduct(pId, dto);
                    if (!ctx.mounted) return;
                    if (success) Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    
    // Filter products by category
    final filteredProducts = _selectedCategoryFilter == null
        ? admin.products
        : admin.products.where((p) => p.categoryId == _selectedCategoryFilter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            const Text(
              'Kelola Barang',
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
                '${filteredProducts.length}',
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
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Tambah', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x050F172A),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  hintText: 'Cari produk, SKU, barcode...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 22),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: (v) => admin.fetchProducts(query: v),
              ),
            ),
          ),
          
          // Luxury Category Filter Tabs
          if (admin.categories.isNotEmpty)
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => setState(() => _selectedCategoryFilter = null),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedCategoryFilter == null ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _selectedCategoryFilter == null ? AppColors.primary : const Color(0xFFE2E8F0),
                          ),
                          boxShadow: _selectedCategoryFilter == null
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          'Semua',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _selectedCategoryFilter == null ? Colors.white : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                  ),
                  ...admin.categories.map((cat) {
                    final isSel = _selectedCategoryFilter == cat.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => setState(() => _selectedCategoryFilter = isSel ? null : cat.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSel ? AppColors.primary : const Color(0xFFE2E8F0),
                            ),
                            boxShadow: isSel
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            cat.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isSel ? Colors.white : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Expanded(
            child: admin.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredProducts.isEmpty
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
                              child: const Icon(Icons.inventory_2_outlined, size: 32, color: Color(0xFF94A3B8)),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Belum ada produk',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF475569)),
                            ),
                          ],
                        ),
                      )
                    : Builder(builder: (ctx) {
                        final alertCount = filteredProducts.where((p) => p.stock == 0 || (p.minStock > 0 && p.stock <= p.minStock)).length;
                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: filteredProducts.length + (alertCount > 0 ? 1 : 0),
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (ctx, i) {
                            if (alertCount > 0 && i == 0) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFBEB),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFFDE68A)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        '$alertCount produk butuh restock (habis / menipis)',
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFFB45309)),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            final p = filteredProducts[alertCount > 0 ? i - 1 : i];
                            final habis = p.stock == 0;
                            final menipis = !habis && p.minStock > 0 && p.stock <= p.minStock;
                            final catIdx = admin.categories.indexWhere((c) => c.id == p.categoryId);
                            final categoryName = catIdx >= 0 ? admin.categories[catIdx].name : 'Umum';
                            
                            return ModernCard(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top meta row: Category pill + Stock status pill + Menu
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.label_outline_rounded, size: 13, color: Color(0xFF64748B)),
                                            const SizedBox(width: 5),
                                            Text(
                                              categoryName,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF475569),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: habis
                                              ? const Color(0xFFFEF2F2)
                                              : (menipis ? const Color(0xFFFFFBEB) : const Color(0xFFECFDF5)),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: habis
                                                ? const Color(0xFFFECACA)
                                                : (menipis ? const Color(0xFFFDE68A) : const Color(0xFFA7F3D0)),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: habis
                                                    ? const Color(0xFFDC2626)
                                                    : (menipis ? const Color(0xFFD97706) : const Color(0xFF059669)),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              habis
                                                  ? 'Habis'
                                                  : (menipis ? 'Sisa ${p.stock} (Menipis)' : 'Stok ${p.stock}'),
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: habis
                                                    ? const Color(0xFFDC2626)
                                                    : (menipis ? const Color(0xFFB45309) : const Color(0xFF065F46)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Spacer(),
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_horiz_rounded, color: Color(0xFF94A3B8), size: 20),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        itemBuilder: (ctx) => [
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit_outlined, size: 18, color: Color(0xFF475569)),
                                                SizedBox(width: 8),
                                                Text('Edit Produk', style: TextStyle(fontWeight: FontWeight.w600)),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFDC2626)),
                                                SizedBox(width: 8),
                                                Text('Hapus', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFDC2626))),
                                              ],
                                            ),
                                          ),
                                        ],
                                        onSelected: (val) {
                                          if (val == 'edit') _showForm(product: p);
                                          if (val == 'delete') admin.deleteProduct(p.id);
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Product Main Info: Icon + Name + Barcode
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: const Color(0xFFBBF7D0)),
                                        ),
                                        child: const Icon(
                                          Icons.inventory_2_rounded,
                                          color: Color(0xFF0F3826),
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              p.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16,
                                                color: Color(0xFF0F172A),
                                                letterSpacing: -0.2,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.qr_code_2_rounded, size: 14, color: Color(0xFF94A3B8)),
                                                const SizedBox(width: 4),
                                                Text(
                                                  p.barcode != null && p.barcode!.isNotEmpty
                                                      ? p.barcode!
                                                      : 'SKU: ${p.sku}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF64748B),
                                                    fontFamily: 'monospace',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 14),
                                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                  const SizedBox(height: 12),

                                  // Bottom Row: Price & Quick Action
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'HARGA JUAL',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF94A3B8),
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Rp ${AppUtils.formatCurrency(p.price)}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFF0F3826),
                                              letterSpacing: -0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                      InkWell(
                                        borderRadius: BorderRadius.circular(10),
                                        onTap: () => _showForm(product: p),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF8FAFC),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: const Color(0xFFE2E8F0)),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.edit_outlined, size: 14, color: Color(0xFF0F3826)),
                                              SizedBox(width: 6),
                                              Text(
                                                'Edit',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF0F3826),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }),
          ),
        ],
      ),
    );
  }
}