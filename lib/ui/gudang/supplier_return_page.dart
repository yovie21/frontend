import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils.dart';
import '../../../providers/gudang_provider.dart';
import '../../../providers/admin_provider.dart';

class SupplierReturnPage extends StatefulWidget {
  const SupplierReturnPage({super.key});

  @override
  State<SupplierReturnPage> createState() => _SupplierReturnPageState();
}

class _SupplierReturnPageState extends State<SupplierReturnPage> {
  List<dynamic> _returns = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchReturns();
  }

  Future<void> _fetchReturns() async {
    final admin = context.read<AdminProvider>();
    final data = await admin.fetchSupplierReturns();
    if (mounted) {
      setState(() {
        _returns = data;
        _loading = false;
      });
    }
  }

  void _showAddReturnModal() {
    final gudang = context.read<GudangProvider>();
    final admin = context.read<AdminProvider>();

    if (admin.suppliers.isEmpty || admin.products.isEmpty) {
      admin.fetchSuppliers();
      admin.fetchProducts();
    }

    int? selectedSupplier = admin.suppliers.isNotEmpty ? admin.suppliers.first.id : null;
    int? selectedProduct = admin.products.isNotEmpty ? admin.products.first.id : null;
    final qtyCtrl = TextEditingController(text: '1');
    final reasonCtrl = TextEditingController(text: 'Barang rusak / expired');
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) => Container(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Form Retur Supplier', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: selectedSupplier,
                decoration: const InputDecoration(labelText: 'Pilih Supplier'),
                items: admin.suppliers.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                onChanged: (v) => setM(() => selectedSupplier = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: selectedProduct,
                decoration: const InputDecoration(labelText: 'Pilih Produk'),
                items: admin.products.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                onChanged: (v) => setM(() => selectedProduct = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Jumlah Qty Retur'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                decoration: const InputDecoration(labelText: 'Alasan Retur'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: isSaving ? null : () async {
                  if (selectedSupplier == null || selectedProduct == null) return;
                  final q = int.tryParse(qtyCtrl.text) ?? 0;
                  if (q <= 0) return;

                  setM(() => isSaving = true);
                  final ok = await admin.createSupplierReturn(
                    supplierId: selectedSupplier!,
                    productId: selectedProduct!,
                    qty: q,
                    reason: reasonCtrl.text,
                  );
                  if (mounted && ok) {
                    Navigator.pop(ctx);
                    _fetchReturns();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Retur supplier berhasil dicatat')),
                    );
                  } else {
                    setM(() => isSaving = false);
                  }
                },
                child: isSaving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Simpan Retur', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Retur Barang Supplier'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_rounded, size: 28),
            onPressed: _showAddReturnModal,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _returns.isEmpty
              ? const Center(child: Text('Belum ada riwayat retur barang'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _returns.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) {
                    final item = _returns[i];
                    final supplierName = item['supplier']?['name'] ?? 'Supplier';
                    final productName = item['product']?['name'] ?? 'Produk';
                    final qty = item['qty'] ?? 0;
                    final reason = item['reason'] ?? '-';
                    final date = item['createdAt'] != null ? AppUtils.formatDate(DateTime.parse(item['createdAt'])) : '-';

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(supplierName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                              Text(date, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('Barang: $productName ($qty Pcs)', style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('Alasan: $reason', style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
