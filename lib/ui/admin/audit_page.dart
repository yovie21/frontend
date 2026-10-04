import 'package:flutter/material.dart';
import '../../../core/utils.dart';
import '../../../data/services/services.dart';

class AuditPage extends StatefulWidget {
  const AuditPage({super.key});

  @override
  State<AuditPage> createState() => _AuditPageState();
}

class _AuditPageState extends State<AuditPage> {
  List<dynamic> rows = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await AuditService.getLogs();
      if (!mounted) return;
      setState(() {
        rows = r;
        loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  static const _actions = {
    'create': 'Membuat',
    'update': 'Mengubah',
    'delete': 'Menghapus',
    'pay': 'Membayar',
    'receive': 'Menerima',
    'login': 'Masuk',
    'return_supplier': 'Retur',
  };

  static const _entities = {
    'purchase_order': 'Purchase Order',
    'sale': 'Penjualan',
    'product': 'Produk',
    'category': 'Kategori',
    'supplier': 'Supplier',
    'user': 'Pengguna',
    'promo': 'Promo',
    'stock': 'Stok',
    'supplier_return': 'Retur Supplier',
    'cash_reconcile': 'Rekonsiliasi Kas',
  };

  String _label(String? raw, Map<String, String> map) {
    final k = (raw ?? '').toLowerCase();
    if (map.containsKey(k)) return map[k]!;
    if (k.isEmpty) return '-';
    return k[0].toUpperCase() + k.substring(1).replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Log Aktivitas', style: TextStyle(fontWeight: FontWeight.w800))),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : rows.isEmpty
              ? const Center(child: Text('Belum ada aktivitas'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final r = rows[i] as Map<String, dynamic>;
                    final user = r['user'] as Map<String, dynamic>?;
                    final action = _label(r['action']?.toString(), _actions);
                    final entity = _label(r['entity']?.toString(), _entities);
                    final id = r['entityId'];
                    final ref = id == null ? '' : ' · ID $id';
                    return ListTile(
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      title: Text('$action $entity$ref', style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('${user?['username'] ?? '-'} · ${AppUtils.formatDate(r['createdAt'])}'),
                    );
                  },
                ),
    );
  }
}
