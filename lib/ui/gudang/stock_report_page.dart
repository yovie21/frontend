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
      appBar: AppBar(title: const Text('Laporan Stok Menipis')),
      body: RefreshIndicator(
        onRefresh: () => gudang.fetchStockReport(),
        child: gudang.isLoading
            ? const Center(child: CircularProgressIndicator())
            : gudang.lowStockProducts.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                        SizedBox(height: 16),
                        Text('Semua stok produk aman!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: gudang.lowStockProducts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final p = gudang.lowStockProducts[i];
                      return ModernCard(
                        padding: const EdgeInsets.all(12),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(color: const Color(0xFFF8EDE8), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFD46B3D)),
                          ),
                          title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('SKU: ${p.sku}', style: const TextStyle(color: Color(0xFF5A5A5A))),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8EDE8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Stok: ${p.stock} / Min: ${p.minStock}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD46B3D), fontSize: 12),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
