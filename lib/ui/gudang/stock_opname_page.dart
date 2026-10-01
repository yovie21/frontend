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
    final totalProduk = gudang.products.length;
    final totalStok = gudang.products.fold(0, (sum, p) => sum + p.stock);
    final habisCount = gudang.products.where((p) => p.stock == 0).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Stok Opname Gudang',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => gudang.fetchProducts(),
        child: gudang.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  // Luxury Executive Summary Banner
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F3826), Color(0xFF1B5E3C), Color(0xFF0D281C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x300F3826),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.warehouse_rounded, color: Color(0xFFD4AF37), size: 22),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'MONITORING INVENTARIS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFD4AF37),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Total Produk', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$totalProduk SKU',
                                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                                  ),
                                ],
                              ),
                            ),
                            Container(width: 1, height: 35, color: Colors.white.withOpacity(0.15)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Total Qty Unit', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$totalStok Pcs',
                                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                                  ),
                                ],
                              ),
                            ),
                            if (habisCount > 0) ...[
                              Container(width: 1, height: 35, color: Colors.white.withOpacity(0.15)),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Stok Habis', style: TextStyle(color: Color(0xFFFCA5A5), fontSize: 12, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$habisCount SKU',
                                      style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 20, fontWeight: FontWeight.w900),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'DAFTAR STOK BARANG',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (gudang.products.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.warehouse_outlined, size: 32, color: Color(0xFF94A3B8)),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Belum ada produk di gudang',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF475569)),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: gudang.products.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) {
                        final p = gudang.products[i];
                        final habis = p.stock == 0;
                        final low = !habis && p.stock <= p.minStock;
                        return ModernCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: habis
                                        ? [const Color(0xFFFEF2F2), const Color(0xFFFEE2E2)]
                                        : (low
                                            ? [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)]
                                            : [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)]),
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: habis
                                        ? const Color(0xFFFECACA)
                                        : (low ? const Color(0xFFFDE68A) : const Color(0xFFBBF7D0)),
                                  ),
                                ),
                                child: Icon(
                                  Icons.warehouse_rounded,
                                  color: habis
                                      ? const Color(0xFFDC2626)
                                      : (low ? const Color(0xFFD97706) : const Color(0xFF0F3826)),
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
                                        fontSize: 15.5,
                                        color: Color(0xFF0F172A),
                                        letterSpacing: -0.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          'SKU: ${p.sku}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF64748B),
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: habis
                                                ? const Color(0xFFFEF2F2)
                                                : (low ? const Color(0xFFFFFBEB) : const Color(0xFFECFDF5)),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            habis ? 'Habis' : (low ? 'Sisa ${p.stock}' : 'Stok ${p.stock}'),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: habis
                                                  ? const Color(0xFFDC2626)
                                                  : (low ? const Color(0xFFB45309) : const Color(0xFF065F46)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () => _showAdjustDialog(p.id, p.name, p.stock),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.tune_rounded, size: 16, color: Color(0xFF0F3826)),
                                      SizedBox(width: 6),
                                      Text(
                                        'Sesuaikan',
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
                        );
                      },
                    ),
                ],
              ),
      ),
    );
  }
}
