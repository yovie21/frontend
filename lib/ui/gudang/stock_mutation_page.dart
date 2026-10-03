import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils.dart';
import '../../data/services/services.dart';
import '../../providers/admin_provider.dart';

class StockMutationPage extends StatefulWidget {
  const StockMutationPage({super.key});

  @override
  State<StockMutationPage> createState() => _StockMutationPageState();
}

class _StockMutationPageState extends State<StockMutationPage> {
  bool _isLoading = false;
  List<dynamic> _transactions = [];
  int? _selectedProductId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final admin = context.read<AdminProvider>();
      if (admin.products.isEmpty) {
        await admin.fetchProducts();
      }
      final txs = _selectedProductId == null
          ? await StockServiceExt.getAllStockHistory()
          : await StockServiceExt.getStockHistory(_selectedProductId!);
      if (mounted) {
        setState(() {
          _transactions = txs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Kartu & Mutasi Stok',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          // Filter Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.history_rounded, color: Color(0xFF2563EB), size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Filter Riwayat Produk',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                    ),
                    if (_selectedProductId != null)
                      TextButton.icon(
                        onPressed: () {
                          setState(() => _selectedProductId = null);
                          _loadData();
                        },
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('Reset', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: _selectedProductId,
                      isExpanded: true,
                      hint: const Text('Semua Produk (Semua Mutasi)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Semua Produk', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                        ),
                        ...admin.products.map(
                          (p) => DropdownMenuItem<int?>(
                            value: p.id,
                            child: Text(
                              '${p.name} (Stok: ${p.stock})',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() => _selectedProductId = val);
                        _loadData();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text('Error: $_errorMessage', textAlign: TextAlign.center),
                          ),
                        )
                      : _transactions.isEmpty
                          ? ListView(
                              children: const [
                                SizedBox(height: 100),
                                Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.swap_vert_rounded, size: 56, color: Color(0xFF94A3B8)),
                                      SizedBox(height: 12),
                                      Text(
                                        'Belum ada transaksi mutasi stok',
                                        style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: _transactions.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (ctx, i) {
                                final tx = _transactions[i] as Map<String, dynamic>;
                                final int qtyChange = tx['qtyChange'] ?? 0;
                                final String refType = tx['refType'] ?? 'adjust';
                                final product = tx['product'] as Map<String, dynamic>?;
                                final String prodName = product?['name'] ?? 'Produk';
                                final String sku = product?['sku'] ?? '-';
                                final DateTime createdAt = DateTime.tryParse(tx['createdAt']?.toString() ?? '') ?? DateTime.now();

                                return _buildMutationCard(
                                  prodName: prodName,
                                  sku: sku,
                                  qtyChange: qtyChange,
                                  refType: refType,
                                  refId: tx['refId'],
                                  date: createdAt,
                                );
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMutationCard({
    required String prodName,
    required String sku,
    required int qtyChange,
    required String refType,
    required dynamic refId,
    required DateTime date,
  }) {
    Color badgeBg;
    Color badgeColor;
    String badgeText;
    IconData typeIcon;

    if (refType == 'purchase') {
      badgeBg = const Color(0xFFECFDF5);
      badgeColor = const Color(0xFF059669);
      badgeText = 'KULAKAN PO${refId != null ? ' #$refId' : ''}';
      typeIcon = Icons.arrow_downward_rounded;
    } else if (refType == 'sale') {
      badgeBg = const Color(0xFFFEF2F2);
      badgeColor = const Color(0xFFDC2626);
      badgeText = 'PENJUALAN KASIR${refId != null ? ' #$refId' : ''}';
      typeIcon = Icons.arrow_upward_rounded;
    } else {
      badgeBg = const Color(0xFFFFFBEB);
      badgeColor = const Color(0xFFD97706);
      badgeText = 'PENYESUAIAN OPNAME';
      typeIcon = Icons.tune_rounded;
    }

    final isPositive = qtyChange > 0;
    final signStr = isPositive ? '+$qtyChange' : '$qtyChange';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x040F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: badgeColor.withOpacity(0.3)),
            ),
            child: Icon(typeIcon, color: badgeColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        prodName,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      signStr,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: isPositive ? const Color(0xFF059669) : const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: badgeColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SKU: $sku',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  AppUtils.formatDate(date),
                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
