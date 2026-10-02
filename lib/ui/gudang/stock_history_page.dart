import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils.dart';
import '../../../providers/admin_provider.dart';

class StockHistoryPage extends StatefulWidget {
  final int productId;
  final String productName;
  const StockHistoryPage({required this.productId, required this.productName, super.key});

  @override
  State<StockHistoryPage> createState() => _StockHistoryPageState();
}

class _StockHistoryPageState extends State<StockHistoryPage> {
  bool _loading = true;
  List<dynamic> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final admin = context.read<AdminProvider>();
    final res = await admin.fetchStockHistory(widget.productId);
    if (mounted) {
      setState(() {
        _history = res;
        _loading = false;
      });
    }
  }

  String _formatRefType(String type) {
    switch (type) {
      case 'purchase': return 'Barang Masuk (PO)';
      case 'sale': return 'Penjualan (Kasir)';
      case 'adjust': return 'Penyesuaian (Opname)';
      case 'return': return 'Retur Supplier';
      default: return type;
    }
  }

  Color _badgeColor(int qty) {
    if (qty > 0) return const Color(0xFF16A34A);
    return const Color(0xFFDC2626);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Kartu Stok · ${widget.productName}'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? const Center(child: Text('Belum ada riwayat mutasi stok'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _history.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) {
                    final item = _history[i];
                    final qty = (item['qtyChange'] as num?)?.toInt() ?? 0;
                    final date = item['createdAt'] != null ? AppUtils.formatDate(DateTime.parse(item['createdAt'])) : '-';

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _badgeColor(qty).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              qty > 0 ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                              color: _badgeColor(qty),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatRefType(item['refType'] ?? ''),
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  date,
                                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${qty > 0 ? '+' : ''}$qty',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _badgeColor(qty),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
