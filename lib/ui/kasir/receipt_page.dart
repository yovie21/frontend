import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils.dart';
import '../../../data/models/models.dart';
import '../../../data/services/services.dart';
import '../../../providers/kasir_provider.dart';
import '../widgets/modern_widgets.dart';

class ReceiptPage extends StatefulWidget {
  const ReceiptPage({super.key});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  String _range = 'semua';

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
    } catch (e) {
      debugPrint('Receipt detail error: $e');
    }

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
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
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'STRUK RESMI PENJUALAN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'WARUNGKU',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nota: ${s.nota} · ${AppUtils.formatDate(s.saleDate)}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 14),
                if (detail != null && detail['items'] is List)
                  for (final it in detail['items'])
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${it['product']?['name'] ?? 'Item'} x${it['qty']}',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1E293B)),
                            ),
                          ),
                          Text(
                            'Rp ${AppUtils.formatCurrency(it['qty'] * it['unitPrice'])}',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A)),
                          ),
                        ],
                      ),
                    ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 12),
                if (s.discount > 0) _row('Diskon', -s.discount, color: const Color(0xFFDC2626)),
                _row('Total Transaksi', s.total, bold: true, fontSize: 16),
                const SizedBox(height: 4),
                _row('Metode Bayar', 0, customVal: s.paymentMethod.toUpperCase()),
                _row('Tunai Diterima', s.cashPaid),
                _row('Kembalian', s.changeGiven, bold: true),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: const Text(
                    'Terima kasih atas kunjungan Anda!',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String l, double v, {bool bold = false, double fontSize = 13, Color? color, String? customVal}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              fontSize: fontSize,
              color: bold ? const Color(0xFF0F172A) : const Color(0xFF64748B),
            ),
          ),
          Text(
            customVal ?? 'Rp ${AppUtils.formatCurrency(v)}',
            style: TextStyle(
              fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
              fontSize: fontSize,
              color: color ?? (bold ? const Color(0xFF0F3826) : const Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );
  }

  List<Sale> _filterSales(List<Sale> all) {
    if (_range == 'semua') return all;
    final now = DateTime.now();
    return all.where((s) {
      if (s.saleDate == null) return false;
      final d = DateTime.tryParse(s.saleDate!);
      if (d == null) return false;
      switch (_range) {
        case 'hari':
          return d.year == now.year && d.month == now.month && d.day == now.day;
        case 'minggu':
          final startOfWeek = now.subtract(const Duration(days: 7));
          return d.isAfter(startOfWeek);
        case 'bulan':
          return d.year == now.year && d.month == now.month;
        case 'tahun':
          return d.year == now.year;
        default:
          return true;
      }
    }).toList();
  }

  Widget _filterTab(String key, String label) {
    final isSel = _range == key;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _range = key),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSel ? const Color(0xFF0F3826) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSel ? const Color(0xFF0F3826) : const Color(0xFFE2E8F0),
            ),
            boxShadow: isSel
                ? [
                    BoxShadow(
                      color: const Color(0xFF0F3826).withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSel ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kasir = context.watch<KasirProvider>();
    final filtered = _filterSales(kasir.salesHistory);
    final totalOmset = filtered.fold<double>(0.0, (sum, s) => sum + s.total);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            const Text(
              'Riwayat Penjualan',
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
                '${filtered.length}',
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
      body: Column(
        children: [
          // Filter Tabs: Hari, Minggu, Bulan, Tahun, Semua
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterTab('hari', 'Hari Ini'),
                  _filterTab('minggu', 'Minggu Ini'),
                  _filterTab('bulan', 'Bulan Ini'),
                  _filterTab('tahun', 'Tahun Ini'),
                  _filterTab('semua', 'Semua'),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Sub-header Summary Banner: Total Omset Periode Terpilih
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFF1F5F9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_rounded, size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(
                      '${filtered.length} Transaksi',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: Color(0xFF475569)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      'Total: ',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Rp ${AppUtils.formatCurrency(totalOmset)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F3826),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () => kasir.fetchSalesHistory(),
              child: kasir.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
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
                                child: const Icon(Icons.receipt_long_outlined, size: 32, color: Color(0xFF94A3B8)),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Tidak ada transaksi pada periode ini',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF475569)),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (ctx, i) {
                            final s = filtered[i];
                            return ModernCard(
                        padding: const EdgeInsets.all(16),
                        onTap: () => _showDetail(s),
                        child: Row(
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
                              child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF0F3826), size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        s.nota,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14.5,
                                          color: Color(0xFF0F172A),
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          s.paymentMethod.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF475569),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppUtils.formatDate(s.saleDate),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Rp ${AppUtils.formatCurrency(s.total)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15.5,
                                    color: Color(0xFF0F3826),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                if (s.discount > 0)
                                  Text(
                                    'Disc: Rp ${AppUtils.formatCurrency(s.discount)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFDC2626),
                                    ),
                                  ),
                              ],
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
