import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/utils.dart';
import '../../../data/models/models.dart';
import '../../../providers/gudang_provider.dart';
import '../../../providers/admin_provider.dart';

class PoPage extends StatefulWidget {
  const PoPage({super.key});

  @override
  State<PoPage> createState() => _PoPageState();
}

class _PoPageState extends State<PoPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GudangProvider>().fetchPurchaseOrders();
    });
  }

  Future<void> _createPo() async {
    final gudang = context.read<GudangProvider>();
    if (gudang.suppliers.isEmpty || gudang.products.isEmpty) {
      await gudang.fetchPurchaseOrders();
    }
    if (gudang.suppliers.isEmpty || gudang.products.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Isi supplier dan produk di menu Admin dulu')),
        );
      }
      return;
    }

    int supplierId = gudang.suppliers.first.id;
    List<Map<String, dynamic>> items = [
      {
        'productId': gudang.products.first.id,
        'qtyCtrl': TextEditingController(text: '1'),
        'priceCtrl': TextEditingController(
          text: AppUtils.formatCurrency(gudang.products.first.costPrice.toInt()),
        ),
      }
    ];

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) {
          double grandTotal = 0;
          for (var it in items) {
            final q = int.tryParse(it['qtyCtrl'].text) ?? 0;
            final p = AppUtils.parseCurrency(it['priceCtrl'].text);
            grandTotal += (q * p);
          }

          return Container(
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
                      const Text('PO Baru', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx, false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: supplierId,
                    decoration: const InputDecoration(labelText: 'Supplier *', prefixIcon: Icon(Icons.business)),
                    items: gudang.suppliers.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                    onChanged: (v) => setM(() => supplierId = v ?? supplierId),
                  ),
                  const SizedBox(height: 16),
                  const Text('Daftar Barang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  for (int i = 0; i < items.length; i++) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: items[i]['productId'],
                                  decoration: InputDecoration(labelText: 'Produk ${i + 1}'),
                                  items: gudang.products
                                      .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                                      .toList(),
                                  onChanged: (v) {
                                    final p = gudang.products.firstWhere((e) => e.id == v);
                                    setM(() {
                                      items[i]['productId'] = v;
                                      items[i]['priceCtrl'].text = AppUtils.formatCurrency(p.costPrice.toInt());
                                    });
                                  },
                                ),
                              ),
                              if (items.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => setM(() => items.removeAt(i)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: items[i]['qtyCtrl'],
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: const InputDecoration(labelText: 'Qty'),
                                  onChanged: (_) => setM(() {}),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: items[i]['priceCtrl'],
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
                                  decoration: const InputDecoration(labelText: 'Harga Satuan', prefixText: 'Rp '),
                                  onChanged: (_) => setM(() {}),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  TextButton.icon(
                    onPressed: () => setM(() {
                      items.add({
                        'productId': gudang.products.first.id,
                        'qtyCtrl': TextEditingController(text: '1'),
                        'priceCtrl': TextEditingController(
                          text: AppUtils.formatCurrency(gudang.products.first.costPrice.toInt()),
                        ),
                      });
                    }),
                    icon: const Icon(Icons.add),
                    label: const Text('+ Tambah Barang Lain'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Estimasi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        'Rp ${AppUtils.formatCurrency(grandTotal)}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1B3B2B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Buat PO (Draft)'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    if (ok != true || !mounted) return;

    final payloadItems = <Map<String, dynamic>>[];
    for (var it in items) {
      final q = int.tryParse(it['qtyCtrl'].text) ?? 0;
      final p = AppUtils.parseCurrency(it['priceCtrl'].text);
      if (q > 0 && p > 0) {
        payloadItems.add({
          'productId': it['productId'],
          'qty': q,
          'unitPrice': p,
        });
      }
    }

    if (payloadItems.isEmpty) return;

    final success = await gudang.createPurchaseOrder({
      'supplierId': supplierId,
      'items': payloadItems,
    });

    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(gudang.errorMessage ?? 'Gagal membuat PO')),
      );
    }
  }

  void _showDetail(PurchaseOrder po) {
    final name = po.supplier?['name']?.toString() ?? 'Supplier';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('PO #${po.id} · $name', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(po.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      po.status.toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.bold, color: _statusColor(po.status), fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Tanggal Order: ${AppUtils.formatDate(po.orderDate)}',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
              const Divider(height: 24),
              const Text('Daftar Barang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 12),
              for (final it in po.items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              it['productName'] ?? it['product']?['name'] ?? 'Produk',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            Text(
                              '${it['qty']} x Rp ${AppUtils.formatCurrency(it['unitPrice'])}',
                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Rp ${AppUtils.formatCurrency((it['qty'] ?? 1) * (it['unitPrice'] ?? 0))}',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Pembelian', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  Text(
                    'Rp ${AppUtils.formatCurrency(po.totalAmount)}',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1B3B2B)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'received':
        return const Color(0xFF16A34A);
      case 'ordered':
        return const Color(0xFFD97706);
      case 'canceled':
        return const Color(0xFF94A3B8);
      default:
        return const Color(0xFF475569);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gudang = context.watch<GudangProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Order'),
        actions: [IconButton(icon: const Icon(Icons.add_circle, size: 28), onPressed: _createPo)],
      ),
      body: RefreshIndicator(
        onRefresh: () => gudang.fetchPurchaseOrders(),
        child: gudang.isLoading
            ? const Center(child: CircularProgressIndicator())
            : gudang.purchaseOrders.isEmpty
                ? const Center(child: Text('Belum ada PO'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: gudang.purchaseOrders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final po = gudang.purchaseOrders[i];
                      final name = po.supplier?['name']?.toString() ?? 'Supplier';
                      final itemCount = po.items.length;
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          onTap: () => _showDetail(po),
                          title: Text('#${po.id} · $name', style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(
                            '${po.status.toUpperCase()} · $itemCount barang · Rp ${AppUtils.formatCurrency(po.totalAmount)}',
                            style: TextStyle(color: _statusColor(po.status), fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          trailing: _actions(po, gudang),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Widget? _actions(PurchaseOrder po, GudangProvider gudang) {
    if (po.status == 'draft') {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706)),
        onPressed: () => gudang.updatePurchaseOrderStatus(po.id, 'ordered'),
        child: const Text('Pesan'),
      );
    }
    if (po.status == 'ordered') {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
        onPressed: () async {
          final ok = await gudang.updatePurchaseOrderStatus(po.id, 'received');
          if (ok && mounted) {
            context.read<AdminProvider>().fetchProducts();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Stok semua barang dalam PO berhasil ditambahkan!')),
            );
          }
        },
        child: const Text('Terima'),
      );
    }
    return null;
  }
}
