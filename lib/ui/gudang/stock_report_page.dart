import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/gudang_provider.dart';
import '../widgets/modern_widgets.dart';

class StockReportPage extends StatefulWidget {
  const StockReportPage({super.key});

  @override
  State<StockReportPage> createState() => _StockReportPageState();
}

class _StockReportPageState extends State<StockReportPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GudangProvider>().fetchStockReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gudang = context.watch<GudangProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            const Text(
              'Stok Menipis & Habis',
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
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Text(
                '${gudang.lowStockProducts.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFB45309),
                ),
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => gudang.fetchStockReport(),
        child: gudang.isLoading
            ? const Center(child: CircularProgressIndicator())
            : gudang.lowStockProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: const Icon(Icons.check_circle_rounded, size: 36, color: Color(0xFF059669)),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Semua Stok Produk Aman!',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tidak ada produk yang perlu di-restock.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: gudang.lowStockProducts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final p = gudang.lowStockProducts[i];
                      final habis = p.stock == 0;
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
                                      : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: habis ? const Color(0xFFFECACA) : const Color(0xFFFDE68A),
                                ),
                              ),
                              child: Icon(
                                habis ? Icons.cancel_outlined : Icons.warning_amber_rounded,
                                color: habis ? const Color(0xFFDC2626) : const Color(0xFFD97706),
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
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'SKU: ${p.sku}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF64748B),
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: habis ? const Color(0xFFFEF2F2) : const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: habis ? const Color(0xFFFECACA) : const Color(0xFFFDE68A),
                                ),
                              ),
                              child: Text(
                                habis ? 'Habis (0)' : 'Sisa ${p.stock} (Min: ${p.minStock})',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: habis ? const Color(0xFFDC2626) : const Color(0xFFB45309),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
