import 'package:flutter/material.dart';
import '../../../core/utils.dart';
import '../../../data/services/services.dart';
import '../widgets/modern_widgets.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  Map<String, dynamic>? _data;
  String? _error;
  bool _loading = true;
  String _range = 'hari';
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final now = DateTime.now();
      DateTime from;
      DateTime to = DateTime(now.year, now.month, now.day, 23, 59, 59);
      if (_range == 'hari') {
        from = DateTime(now.year, now.month, now.day);
      } else if (_range == 'minggu') {
        from = now.subtract(const Duration(days: 7));
      } else if (_range == 'bulan') {
        from = DateTime(now.year, now.month, 1);
      } else if (_range == 'kustom' && _customRange != null) {
        from = DateTime(_customRange!.start.year, _customRange!.start.month, _customRange!.start.day);
        to = DateTime(_customRange!.end.year, _customRange!.end.month, _customRange!.end.day, 23, 59, 59);
      } else {
        from = DateTime(now.year, now.month, 1);
      }
      final data = await SaleService.getSalesReport(
        from: from.toIso8601String(),
        to: to.toIso8601String(),
      );
      if (mounted) setState(() => _data = data);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _customRange ?? DateTimeRange(
        start: now.subtract(const Duration(days: 7)),
        end: now,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0F3826),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _range = 'kustom';
        _customRange = picked;
      });
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPenjualan = (_data?['totalPenjualan'] as num?)?.toDouble() ?? 0.0;
    final totalDiskon = (_data?['totalDiskon'] as num?)?.toDouble() ?? 0.0;
    final totalHpp = (_data?['totalHargaPokok'] as num?)?.toDouble() ?? 0.0;
    final labaKotor = (_data?['labaKotor'] as num?)?.toDouble() ?? 0.0;
    final totalCash = (_data?['totalCash'] as num?)?.toDouble() ?? 0.0;
    final totalNonCash = (totalPenjualan - totalCash).clamp(0, double.infinity);
    final transaksi = (_data?['transaksi'] as num?)?.toInt() ?? 0;
    final avgBasket = transaksi > 0 ? (totalPenjualan / transaksi) : 0.0;
    final marginPercent = totalPenjualan > 0 ? ((labaKotor / totalPenjualan) * 100).toStringAsFixed(1) : '0';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Laporan Penjualan & Laba',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Rentang Waktu (Pill Selector)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterPill('hari', 'Hari Ini'),
                  _filterPill('minggu', '7 Hari'),
                  _filterPill('bulan', 'Bulan Ini'),
                  _filterPill(
                    'kustom',
                    _customRange != null
                        ? '${_customRange!.start.day}/${_customRange!.start.month} - ${_customRange!.end.day}/${_customRange!.end.month}'
                        : 'Pilih Tanggal',
                    icon: Icons.calendar_month_rounded,
                    onTapCustom: _pickDateRange,
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFDC2626)),
                            const SizedBox(height: 12),
                            Text('Gagal memuat: $_error', style: const TextStyle(color: Color(0xFF64748B))),
                            const SizedBox(height: 16),
                            ElevatedButton(onPressed: _load, child: const Text('Coba Lagi')),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                          children: [
                            // HERO CARD: Laba Kotor
                            Container(
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF0F3826), Color(0xFF1B5E3C)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x250F3826),
                                    blurRadius: 18,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.auto_graph_rounded, color: Color(0xFF6EE7B7), size: 14),
                                            SizedBox(width: 6),
                                            Text(
                                              'LABA BERSIH (PROFIT)',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white,
                                                letterSpacing: 0.6,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Margin $marginPercent%',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Rp ${AppUtils.formatCurrency(labaKotor)}',
                                    style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: -0.6,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Total profit dari $transaksi transaksi penjualan',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 2x2 GRID METRICS
                            Row(
                              children: [
                                Expanded(
                                  child: _metricBox(
                                    icon: Icons.point_of_sale_rounded,
                                    iconBg: const Color(0xFFEFF6FF),
                                    iconColor: const Color(0xFF2563EB),
                                    title: 'Total Omset',
                                    value: 'Rp ${AppUtils.formatCurrency(totalPenjualan)}',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _metricBox(
                                    icon: Icons.receipt_long_rounded,
                                    iconBg: const Color(0xFFECFDF5),
                                    iconColor: const Color(0xFF059669),
                                    title: 'Transaksi',
                                    value: '$transaksi Struk',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _metricBox(
                                    icon: Icons.inventory_2_outlined,
                                    iconBg: const Color(0xFFFFFBEB),
                                    iconColor: const Color(0xFFD97706),
                                    title: 'Modal (HPP)',
                                    value: 'Rp ${AppUtils.formatCurrency(totalHpp)}',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _metricBox(
                                    icon: Icons.local_offer_outlined,
                                    iconBg: const Color(0xFFFEF2F2),
                                    iconColor: const Color(0xFFDC2626),
                                    title: 'Total Diskon',
                                    value: 'Rp ${AppUtils.formatCurrency(totalDiskon)}',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // REKAP LACI KASIR & PEMBAYARAN
                            const Padding(
                              padding: EdgeInsets.only(left: 4, bottom: 8),
                              child: Text(
                                'KAS LACI & PENERIMAAN KASIR',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF94A3B8),
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x040F172A),
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFECFDF5),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Icons.payments_rounded, color: Color(0xFF059669), size: 18),
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Uang Tunai di Laci Kasir',
                                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A)),
                                            ),
                                            Text(
                                              'Total fisik kas tunai yang harus ada',
                                              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        'Rp ${AppUtils.formatCurrency(totalCash)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                          color: Color(0xFF0F3826),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 20, color: Color(0xFFF1F5F9)),
                                  Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEFF6FF),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Icons.qr_code_rounded, color: Color(0xFF2563EB), size: 18),
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Non-Tunai (QRIS / Transfer)',
                                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A)),
                                            ),
                                            Text(
                                              'Masuk langsung ke rekening toko',
                                              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        'Rp ${AppUtils.formatCurrency(totalNonCash)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          color: Color(0xFF2563EB),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 20, color: Color(0xFFF1F5F9)),
                                  Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFAF5FF),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Icons.shopping_bag_rounded, color: Color(0xFF9333EA), size: 18),
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Rata-rata per Struk',
                                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A)),
                                            ),
                                            Text(
                                              'Nilai belanja rata-rata pelanggan',
                                              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        'Rp ${AppUtils.formatCurrency(avgBasket)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 22),

                            // RINCIAN FINANSIAL SECTION
                            const Padding(
                              padding: EdgeInsets.only(left: 4, bottom: 8),
                              child: Text(
                                'RINCIAN REKAPITULASI OMSET & HPP',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF94A3B8),
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            ModernCard(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                              child: Column(
                                children: [
                                  _detailRow('Penjualan Kotor (Gross)', totalPenjualan + totalDiskon),
                                  const Divider(height: 16, color: Color(0xFFF1F5F9)),
                                  _detailRow('Potongan Diskon Kasir', -totalDiskon, color: const Color(0xFFDC2626)),
                                  const Divider(height: 16, color: Color(0xFFF1F5F9)),
                                  _detailRow('Penjualan Bersih (Net)', totalPenjualan, bold: true),
                                  const Divider(height: 16, color: Color(0xFFF1F5F9)),
                                  _detailRow('Beban Pokok Penjualan (HPP)', -totalHpp, color: const Color(0xFFB45309)),
                                  const Divider(height: 18, color: Color(0xFFE2E8F0)),
                                  _detailRow('Laba Bersih Akhir', labaKotor, bold: true, fontSize: 16, color: const Color(0xFF0F3826)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _filterPill(String key, String label, {IconData? icon, VoidCallback? onTapCustom}) {
    final isSel = _range == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTapCustom ?? () {
          if (_range != key) {
            setState(() => _range = key);
            _load();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSel ? const Color(0xFF0F3826) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: isSel ? Colors.white : const Color(0xFF64748B)),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isSel ? Colors.white : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricBox({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x040F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, double value, {bool bold = false, double fontSize = 13.5, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            fontSize: fontSize,
            color: bold ? const Color(0xFF0F172A) : const Color(0xFF64748B),
          ),
        ),
        Text(
          'Rp ${AppUtils.formatCurrency(value)}',
          style: TextStyle(
            fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
            fontSize: fontSize,
            color: color ?? (bold ? const Color(0xFF0F172A) : const Color(0xFF1E293B)),
          ),
        ),
      ],
    );
  }
}
