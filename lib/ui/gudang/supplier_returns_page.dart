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
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Retur #${ret['id']}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(AppUtils.formatDate(DateTime.tryParse(ret['createdAt']?.toString() ?? '') ?? DateTime.now()),
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                              ],
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
