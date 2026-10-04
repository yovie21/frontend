import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils.dart';
import '../../data/models/models.dart';
import '../../data/services/services.dart';
import '../../providers/admin_provider.dart';

class SupplierReturnsPage extends StatefulWidget {
  const SupplierReturnsPage({super.key});

  @override
  State<SupplierReturnsPage> createState() => _SupplierReturnsPageState();
}

class _SupplierReturnsPageState extends State<SupplierReturnsPage> {
  bool _isLoading = false;
  List<dynamic> _returns = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReturns();
    });
  }

  Future<void> _loadReturns() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final ret = await SupplierReturnService.getSupplierReturns();
      if (mounted) {
        setState(() {
          _returns = ret;
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

  void _showReturnForm() {
    final admin = context.read<AdminProvider>();
    final products = admin.products;
    final suppliers = admin.suppliers;

    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi produk dan supplier di menu Admin dulu')),
      );
      return;
    }

    int? selectedProductId = products.isNotEmpty ? products.first.id : null;
    int? selectedSupplierId;
    final qtyCtrl = TextEditingController(text: '1');
    final reasonCtrl = TextEditingController(text: 'Barang Rusak / Kadaluarsa');
    final noteCtrl = TextEditingController();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Retur Barang ke Supplier', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Pilih Produk', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: selectedProductId,
                      isExpanded: true,
                      items: products.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                      onChanged: (v) => setM(() => selectedProductId = v),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Supplier (Opsional)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: selectedSupplierId,
                      isExpanded: true,
                      hint: const Text('Pilih Supplier (atau Umum)'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('- Umum / Tidak ada -')),
                        ...suppliers.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                      ],
                      onChanged: (v) => setM(() => selectedSupplierId = v),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Jumlah Retur (pcs)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Qty'),
                ),
                const SizedBox(height: 16),
                const Text('Alasan Retur', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: reasonCtrl,
                  decoration: const InputDecoration(labelText: 'Alasan'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                const Text('Catatan Tambahan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F3826),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (selectedProductId == null) return;
                          final qty = int.tryParse(qtyCtrl.text) ?? 0;
                          if (qty <= 0) return;
                          setM(() => isSaving = true);
                          try {
                            await SupplierReturnService.createSupplierReturn(
                              productId: selectedProductId!,
                              supplierId: selectedSupplierId!,
                              qty: qty,
                              reason: reasonCtrl.text.trim(),
                            );
                            if (ctx.mounted) Navigator.pop(ctx);
                            await _loadReturns();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Retur berhasil dicatat')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Gagal: ${e.toString().replaceAll('Exception: ', '')}')),
                              );
                            }
                            setM(() => isSaving = false);
                          }
                        },
                  child: isSaving
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Simpan Retur', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String val, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600)),
          Text(val, style: TextStyle(color: const Color(0xFF0F172A), fontSize: 14, fontWeight: isBold ? FontWeight.w800 : FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Retur Barang ke Supplier', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [IconButton(icon: const Icon(Icons.add_circle, size: 28), onPressed: _showReturnForm)],
      ),
      body: RefreshIndicator(
        onRefresh: _loadReturns,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text('Error: $_errorMessage'))
                : _returns.isEmpty
                    ? const Center(child: Text('Belum ada retur'))
                    : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _returns.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) {
                        final ret = _returns[i];
                        final id = ret['id'];
                        final qty = ret['qty'] ?? 0;
                        final reason = ret['reason'] ?? '-';
                        final supplier = ret['supplier']?['name'] ?? '- Umum / Tanpa Supplier -';
                        final product = ret['product']?['name'] ?? 'Produk';
                        final sku = ret['product']?['sku'] ?? '-';
                        final costPrice = (ret['product']?['costPrice'] as num?)?.toDouble() ?? 0;
                        final totalValue = qty * costPrice;
                        final dateStr = ret['createdAt'] != null
                            ? AppUtils.formatDate(DateTime.tryParse(ret['createdAt'].toString()) ?? DateTime.now())
                            : '-';

                        return InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                              builder: (ctx) => Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Detail Retur #$id', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                                      ],
                                    ),
                                    const Divider(),
                                    const SizedBox(height: 8),
                                    _detailRow('Tanggal', dateStr),
                                    _detailRow('Supplier', supplier),
                                    _detailRow('Nama Produk', product),
                                    _detailRow('SKU', sku),
                                    _detailRow('Jumlah Retur', '$qty Pcs'),
                                    _detailRow('Harga Beli Satuan', 'Rp ${AppUtils.formatCurrency(costPrice)}'),
                                    _detailRow('Total Estimasi', 'Rp ${AppUtils.formatCurrency(totalValue)}', isBold: true),
                                    _detailRow('Alasan Retur', reason),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 4, offset: Offset(0, 2))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(6)),
                                          child: Text('Retur #$id', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFDC2626))),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(dateStr, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                      ],
                                    ),
                                    Text('Rp ${AppUtils.formatCurrency(totalValue)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F3826))),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(product, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A))),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.store_mall_directory_outlined, size: 14, color: Color(0xFF64748B)),
                                    const SizedBox(width: 4),
                                    Text(supplier, style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.inventory_2_outlined, size: 14, color: Color(0xFF64748B)),
                                    const SizedBox(width: 4),
                                    Text('$qty Pcs', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                    children: [
                                      const Text('Alasan: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                      Expanded(child: Text(reason, style: const TextStyle(fontSize: 12, color: Color(0xFF334155)))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      ),
    );
  }
}
