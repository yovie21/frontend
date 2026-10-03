import 'package:flutter/material.dart';
import '../../../data/services/services.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  final csv = TextEditingController();
  bool saving = false;
  String? result;

  @override
  void dispose() {
    csv.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _parse(String text) {
    final lines = text.split(RegExp(r'\r?\n')).map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    if (lines.isEmpty) return [];
    final header = lines.first.toLowerCase().contains('sku');
    final start = header ? 1 : 0;
    final rows = <Map<String, dynamic>>[];
    for (var i = start; i < lines.length; i++) {
      final c = lines[i].split(RegExp(r'[,;]')).map((s) => s.trim()).toList();
      if (c.length < 4) continue;
      rows.add({
        'sku': c[0],
        'name': c[1],
        'price': double.tryParse(c[2]) ?? 0,
        'costPrice': double.tryParse(c[3]) ?? 0,
        if (c.length > 4 && c[4].isNotEmpty) 'barcode': c[4],
        if (c.length > 5) 'minStock': int.tryParse(c[5]) ?? 0,
        if (c.length > 6) 'initialStock': int.tryParse(c[6]) ?? 0,
      });
    }
    return rows;
  }

  Future<void> _save() async {
    final rows = _parse(csv.text);
    if (rows.isEmpty) {
      setState(() => result = 'Tidak ada baris valid');
      return;
    }
    setState(() => saving = true);
    try {
      final r = await ImportService.importProducts(rows);
      if (!mounted) return;
      setState(() => result = 'Baru ${r['created']} · update ${r['updated']} · gagal ${r['failed']}');
    } catch (e) {
      if (mounted) setState(() => result = '$e');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Import Produk CSV', style: TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Kolom: sku, name, price, costPrice, barcode, minStock, initialStock'),
          const SizedBox(height: 8),
          TextField(
            controller: csv,
            minLines: 8,
            maxLines: 16,
            decoration: const InputDecoration(
              hintText: 'sku,nama,harga,modal,barcode,min,stok\nMIN001,Minyak 1L,18000,15000,,5,20',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: saving ? null : _save, child: Text(saving ? 'Mengunggah...' : 'Import')),
          if (result != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(result!)),
        ],
      ),
    );
  }
}
