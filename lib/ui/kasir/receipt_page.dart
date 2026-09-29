import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/utils.dart';
import '../../../data/models/models.dart';
import '../../../data/services/services.dart';
import '../../../providers/kasir_provider.dart';

class ReceiptPage extends StatefulWidget {
  const ReceiptPage({super.key});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KasirProvider>().fetchSalesHistory();
    });
  }

  void _showDetail(Sale s) async {
    Map<String, dynamic>? detail;
    try {
      detail = await SaleService.getSaleDetail(s.id);
    } catch (_) {}

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('WARUNGKU', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Jl. Random No. 5, Kota X', style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
                const SizedBox(height: 2),
                Text('Tgl ${AppUtils.formatDate(s.saleDate)}', style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
                const SizedBox(height: 2),
                Text('Nota: ${s.nota}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const Divider(height: 24),
                if (detail != null && detail['items'] is List)
                  for (final it in detail['items'])
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${it['product']?['name'] ?? 'Item'} x${it['qty']}'),
                          Text('Rp ${AppUtils.formatCurrency(it['qty'] * it['unitPrice'])}'),
                        ],
                      ),
                    ),
                const Divider(height: 24),
                if (s.discount > 0) _row('Diskon', -s.discount),
                _row('Total', s.total, bold: true),
                _row('Bayar (${s.paymentMethod})', s.cashPaid),
                _row('Kembali', s.changeGiven),
                const SizedBox(height: 12),
                Text('Terima kasih telah berbelanja!', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String l, double v, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w500)),
          Text('Rp ${AppUtils.formatCurrency(v)}', style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kasir = context.watch<KasirProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Penjualan')),
      body: RefreshIndicator(
        onRefresh: () => kasir.fetchSalesHistory(),
        child: kasir.isLoading
            ? const Center(child: CircularProgressIndicator())
            : kasir.salesHistory.isEmpty
                ? const Center(child: Text('Belum ada transaksi'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: kasir.salesHistory.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final s = kasir.salesHistory[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('${s.nota}  Rp ${AppUtils.formatCurrency(s.total)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text('${AppUtils.formatDate(s.saleDate)} · Diskon: Rp ${AppUtils.formatCurrency(s.discount)}', style: const TextStyle(color: Color(0xFF5A5A5A))),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showDetail(s),
                      );
                    },
                  ),
      ),
    );
  }
}
