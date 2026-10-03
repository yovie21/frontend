import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../data/services/services.dart';
import '../../../core/utils.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  Map<String, dynamic>? salesData;
  Map<String, dynamic>? productData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await AnalyticsService.getSalesAnalytics();
      final p = await AnalyticsService.getProductAnalytics();
      if (!mounted) return;
      setState(() {
        salesData = s;
        productData = p;
        loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Analitik Penjualan', style: TextStyle(fontWeight: FontWeight.w800)), backgroundColor: Colors.white, elevation: 0),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (salesData != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ringkasan Penjualan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Omzet'),
                            Text('Rp ${AppUtils.formatCurrency(salesData!['summary']['total'])}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Transaksi'),
                            Text('${salesData!['summary']['txCount']}', style: const TextStyle(fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                const Text('Top Produk Terlaris', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 12),
                if (productData != null)
                  ... (productData!['topProducts'] as List).map((p) => ListTile(
                        leading: CircleAvatar(backgroundColor: AppColors.primary, child: Text('${p['qty']}', style: const TextStyle(color: Colors.white, fontSize: 12))),
                        title: Text(p['name']),
                        trailing: Text('Rp ${AppUtils.formatCurrency(p['revenue'])}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      )),
              ],
            ),
    );
  }
}
