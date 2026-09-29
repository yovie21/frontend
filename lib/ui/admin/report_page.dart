import 'package:flutter/material.dart';
import '../../../core/utils.dart';
import '../../../data/services/services.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  Map<String, dynamic>? _data;
  String? _error;
  bool _loading = true;
  String _range = 'bulan';

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
      if (_range == 'hari') {
        from = DateTime(now.year, now.month, now.day);
      } else if (_range == 'minggu') {
        from = now.subtract(const Duration(days: 7));
      } else {
        from = DateTime(now.year, now.month, 1);
      }
      final data = await SaleService.getSalesReport(
        from: from.toIso8601String(),
        to: now.toIso8601String(),
      );
      if (mounted) setState(() => _data = data);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                for (final r in ['hari', 'minggu', 'bulan'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(r[0].toUpperCase() + r.substring(1)),
                      selected: _range == r,
                      onSelected: (_) {
                        setState(() => _range = r);
                        _load();
                      },
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            _row('Penjualan', _data?['totalPenjualan']),
                            _row('Diskon', _data?['totalDiskon']),
                            _row('Harga pokok', _data?['totalHargaPokok']),
                            const Divider(),
                            _row('Laba kotor', _data?['labaKotor'], bold: true),
                            const SizedBox(height: 8),
                            Text('${_data?['transaksi'] ?? 0} transaksi', style: const TextStyle(color: Color(0xFF5A5A5A))),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, dynamic value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w500, fontSize: bold ? 16 : 14)),
          Text('Rp ${AppUtils.formatCurrency(value)}', style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600, fontSize: bold ? 16 : 14)),
        ],
      ),
    );
  }
}
