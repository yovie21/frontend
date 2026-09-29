import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/gudang_provider.dart';
import '../widgets/modern_widgets.dart';

class StockOpnamePage extends StatefulWidget {
  const StockOpnamePage({super.key});

  @override
  State<StockOpnamePage> createState() => _StockOpnamePageState();
}

class _StockOpnamePageState extends State<StockOpnamePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GudangProvider>().fetchProducts();
    });
  }

  void _showAdjustDialog(int productId, String name, int currentStock) {
    final qtyCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Adjust Stok - $name', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stok Saat Ini: $currentStock', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Perubahan Stok (+/-)', prefixIcon: Icon(Icons.compare_arrows)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              decoration: const InputDecoration(labelText: 'Catatan Penyesuaian', prefixIcon: Icon(Icons.edit_note)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ModernButton(
            text: 'Simpan',
            onPressed: () async {
              final qty = int.tryParse(qtyCtrl.text) ?? 0;
              if (qty == 0) return;

              final gudang = context.read<GudangProvider>();
              final ok = await gudang.adjustStock(productId, qty, note: noteCtrl.text.trim());

              if (mounted) {
                Navigator.pop(ctx);
                if (ok) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stok berhasil disesuaikan')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: ${gudang.errorMessage}')));
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gudang = context.watch<GudangProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Stok Opname Gudang')),
      body: RefreshIndicator(
        onRefresh: () => gudang.fetchProducts(),
        child: gudang.isLoading
            ? const Center(child: CircularProgressIndicator())
            : gudang.products.isEmpty
                ? const Center(child: Text('Belum ada produk'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: gudang.products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final p = gudang.products[i];
                      final low = p.stock <= p.minStock;
                      return ModernCard(
                        padding: const EdgeInsets.all(12),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: low ? const Color(0xFFF8EDE8) : const Color(0xFFE7F0EA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.warehouse, color: low ? const Color(0xFFD46B3D) : const Color(0xFF2D3A2B)),
                          ),
                          title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('SKU: ${p.sku} | Stok: ${p.stock} (Min: ${p.minStock})', style: const TextStyle(color: Color(0xFF5A5A5A))),
                          trailing: IconButton(
                            icon: const Icon(Icons.tune, color: Color(0xFF2D3A2B)),
                            onPressed: () => _showAdjustDialog(p.id, p.name, p.stock),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
